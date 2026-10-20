"""Run the installation/removal matrix in disposable Docker containers."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import json
from pathlib import Path
import shutil
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('channels', type=Path)
parser.add_argument('results', type=Path)
parser.add_argument('--targets', nargs='+')
parser.add_argument('--jobs', type=int, default=2)
parser.add_argument('--images', type=Path, help='Optional target-to-image mapping')
args = parser.parse_args()
channels = json.loads(args.channels.read_text())
results = args.results.resolve()
results.mkdir(parents=True, exist_ok=True)
images = subprocess.check_output(['docker', 'image', 'ls', '--format', '{{.Repository}}:{{.Tag}}'], text=True).splitlines()
custom = json.loads(args.images.read_text()) if args.images else {}
target_channels = {'jammy':'jammy', 'noble':'noble', 'ubuntu2604':'resolute', 'debian13':'debian',
 'fedora43':'fedora', 'fedora44':'fedora', 'fedora45':'fedora',
 'opensuse-leap160':'opensuse', 'opensuse-tumbleweed':'opensuse', 'arch':'arch',
 'linuxmint223':'noble', 'linuxmint7':'debian'}

def check(target):
    directory = results / target
    artifacts = directory / 'artifacts'
    artifacts.mkdir(parents=True, exist_ok=True)
    mapping = {}
    for name, outputs in channels[target_channels[target]].items():
        assert len(outputs) == 1, (target, name, outputs)
        files = [p for p in Path(outputs[0]).iterdir() if p.is_file()]
        assert len(files) == 1, files
        # Hard links avoid duplicating the large vendor payload; fall back across filesystems.
        dst = artifacts / files[0].name
        if not dst.exists():
            try:
                dst.hardlink_to(files[0])
            except OSError:
                shutil.copyfile(files[0], dst)
        mapping[name] = dst.name
    (artifacts / 'packages.json').write_text(json.dumps(mapping))
    image = custom.get(target) or next((i for i in images if i.startswith(f'fdcr-opensc-{target}-x86_64:')), None)
    if not image:
        (directory / 'result.json').write_text(json.dumps({'target': target, 'passed': False, 'error': 'No Docker image available'}, indent=2)+'\n')
        print(target, 'NO IMAGE', flush=True)
        return False
    script = Path(__file__).with_name('container-check.py').resolve()
    process = subprocess.run(['docker', 'run', '--rm', '-v', f'{artifacts}:/artifacts:ro',
        '-v', f'{directory}:/results', '-v', f'{script}:/check.py:ro', image,
        'python3', '/check.py', target], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    (directory / 'installation.log').write_text(process.stdout)
    report_path = directory / 'result.json'
    report = json.loads(report_path.read_text()) if report_path.exists() else {'target': target, 'passed': False}
    report['image'] = image
    report['image_id'] = subprocess.check_output(['docker', 'image', 'inspect', '--format', '{{.Id}}', image], text=True).strip()
    report['artifacts'] = channels[target_channels[target]]
    report_path.write_text(json.dumps(report, indent=2) + '\n')
    print(target, 'PASS' if process.returncode == 0 else 'FAIL', flush=True)
    if process.returncode:
        print('\n'.join(process.stdout.splitlines()[-12:]), flush=True)
    return process.returncode == 0

with ThreadPoolExecutor(max_workers=args.jobs) as pool:
    passed = list(pool.map(check, args.targets or list(target_channels)))
reports = [json.loads(p.read_text()) for p in sorted(results.glob('*/result.json'))]
(results / 'summary.json').write_text(json.dumps(reports, indent=2) + '\n')
raise SystemExit(0 if all(passed) else 1)
