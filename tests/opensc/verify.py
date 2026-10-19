"""Integration audit using prepared distro images; see README.md for invocation."""

import argparse
import json
import subprocess
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("artifacts", type=Path, help="JSON from nix build --json")
parser.add_argument("results", type=Path)
parser.add_argument("--targets", nargs="+", help="Repeat selected distribution cases")
parser.add_argument(
    "--images",
    type=Path,
    help="JSON mapping distro names to images with vanilla OpenSC installed",
)
parser.add_argument("--variants", nargs="+", default=["opensc", "opensc-git"])
args = parser.parse_args()
args.results = args.results.resolve()
args.results.mkdir(parents=True, exist_ok=True)
entries = json.loads(args.artifacts.read_text())
files = [p for e in entries for p in Path(e["outputs"]["out"]).iterdir() if p.is_file()]
derivations = {e["outputs"]["out"]: e["drvPath"] for e in entries}
prepared_images = json.loads(args.images.read_text()) if args.images else {}
images = subprocess.check_output(
    ["docker", "image", "ls", "--format", "{{.Repository}}:{{.Tag}}"], text=True
).splitlines()
targets = args.targets or [
    "jammy",
    "noble",
    "ubuntu2604",
    "debian13",
    "fedora43",
    "fedora44",
    "fedora45",
    "opensuse-leap160",
    "opensuse-tumbleweed",
    "arch",
]


def check(case):
    target, variant = case
    profiles = {
        "jammy": "jammy",
        "noble": "noble",
        "debian13": "debian",
        "ubuntu2604": "ubuntu2604",
        "arch": "arch",
    }
    profile = profiles.get(
        target, "opensuse" if target.startswith("opensuse") else "fedora"
    )
    candidates = [
        p
        for p in files
        if (p.name.startswith("opensc-git") == (variant == "opensc-git"))
    ]
    # The store derivation's name identifies the payload profile even where
    # different native formats use identical archive filenames.
    selected = []
    for p in candidates:
        if profile == "arch" and p.name.endswith(".pkg.tar.zst"):
            selected.append(p)
        elif (
            profile in ("noble", "debian", "ubuntu2604", "jammy")
            and p.name.endswith(".deb")
            or profile in ("fedora", "opensuse")
            and p.name.endswith(".rpm")
        ):
            contents = subprocess.check_output(
                ["nix-store", "-q", "--references", derivations[str(p.parent)]],
                text=True,
            )
            if f"-payload-{profile}.drv\n" in contents:
                selected.append(p)
    assert len(selected) == 1, (target, variant, selected)
    artifact = selected[0]
    image = prepared_images.get(target) or next(
        i for i in images if i.startswith(f"fdcr-opensc-{target}-x86_64:")
    )
    result = args.results / f"{target}-{variant}"
    result.mkdir(exist_ok=True)
    cmd = [
        "docker",
        "run",
        "--rm",
        "-v",
        f"{artifact.parent}:/artifact:ro",
        "-v",
        f"{Path(__file__).with_name('container-check.py').resolve()}:/check.py:ro",
        "-v",
        f"{result}:/results",
        image,
        "python3",
        "/check.py",
        target,
        "/artifact/" + artifact.name,
    ]
    process = subprocess.run(
        cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, check=False
    )
    (result / "installation.log").write_text(process.stdout)
    print(target, variant, "OK" if process.returncode == 0 else "FAILED", flush=True)
    if process.returncode:
        print("\n".join(process.stdout.splitlines()[-8:]), flush=True)
    return process.returncode == 0


with ThreadPoolExecutor(max_workers=5) as pool:
    passed = list(pool.map(check, [(t, p) for t in targets for p in args.variants]))
raise SystemExit(0 if all(passed) else 1)
