"""Static MSI/PE inspection on Linux. Does not verify Windows installation."""
import csv
import io
import json
from pathlib import Path
import re
import subprocess
import sys
import zipfile

installers = json.loads(Path(sys.argv[1]).read_text())
report = {}
for name, installer in installers.items():
    text = subprocess.check_output(['msiinfo', 'export', installer, 'Property'], text=True)
    properties = dict(row for row in list(csv.reader(io.StringIO(text), delimiter='\t'))[3:] if len(row) == 2)
    assert properties['ProductName'] == name
    assert properties['ALLUSERS'] == '1'
    assert 'x64;' in subprocess.check_output(['msiinfo', 'suminfo', installer], text=True)
    destination = Path(name).absolute()
    subprocess.run(['msiextract', '-C', str(destination), installer], check=True, stdout=subprocess.DEVNULL)
    files = list(destination.rglob('*'))
    binaries = [p for p in files if p.suffix.lower() in ('.exe', '.dll')]
    assert binaries
    for binary in binaries:
        data = binary.read_bytes()
        assert data[:2] == b'MZ', binary
        offset = int.from_bytes(data[0x3c:0x40], 'little')
        assert data[offset:offset+6] == b'PE\0\0\x64\x86', binary
    if name.startswith('firmador'):
        assert any(p.name == name + '.exe' for p in binaries)
        assert any(p.name == 'javaw.exe' for p in binaries)
        launcher = next(p for p in binaries if p.name == name + '.exe')
        # The launcher must pass the Java 21 option and "run" so Firmador
        # does not relaunch itself through its Windows-incompatible path.
        assert '--add-exports'.encode('utf-16-le') in launcher.read_bytes()
        jar = next(p for p in files if p.name == 'firmador.jar')
        with zipfile.ZipFile(jar) as archive:
            assert archive.testzip() is None
            signer = next(n for n in archive.namelist() if n.endswith('/CRSigner.class'))
            assert b'java.library.path' in archive.read(signer)
            java21 = 'META-INF/versions/21/Firmador.class'
            if java21 in archive.namelist():
                # URL.getPath() yields /C:/... on Windows.
                assert b'java/nio/file/Paths' in archive.read(java21)
    else:
        module = next(p for p in binaries if p.name == 'opensc-pkcs11.dll')
        assert any(p.name == 'opensc-tool.exe' for p in binaries)
        assert any(p.name == 'opensc.conf' for p in files)
        imports = re.findall(r'DLL Name: (\S+)', subprocess.check_output(['objdump', '-p', str(module)], text=True))
        # PKCS#11 must not depend on a separately installed OpenSC/OpenSSL DLL.
        assert not any(re.search(r'opensc|crypto|ssl|gcc|winpthread', n, re.I) for n in imports), imports
    report[name] = {'msi': installer, 'upgradeCode': properties['UpgradeCode'], 'productCode': properties['ProductCode'], 'peFiles': len(binaries)}
assert report['opensc']['upgradeCode'] == report['opensc-git']['upgradeCode']
assert report['opensc']['productCode'] != report['opensc-git']['productCode']
assert report['firmador']['upgradeCode'] != report['firmador-git']['upgradeCode']
Path(sys.argv[2]).write_text(json.dumps(report, indent=2) + '\n')
