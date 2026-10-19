"""Compare the native archive with the installed distribution package, then install it.

Run inside an unmodified distro image with vanilla opensc installed. The artifact
is mounted at /artifact and this script is mounted read-only at /check.py.
"""

import ctypes
import json
import os
import re
import stat
import subprocess
import sys
from pathlib import Path


def command(*args):
    return subprocess.check_output(args, text=True)


def inventory(root, paths):
    result = {}
    for path in paths:
        path = "/" + path.lstrip("./")
        file = root / path.lstrip("/")
        if file.is_symlink():
            result[path] = {"type": "symlink", "target": os.readlink(file)}
        elif file.is_file():
            result[path] = {"type": "file"}
    return result


target, artifact = sys.argv[1:]
apt = artifact.endswith(".deb")
arch = artifact.endswith(".pkg.tar.zst")
if apt:
    original_version = command(
        "dpkg-query", "-W", "-f=${Package} ${Version}\n", "opensc", "opensc-pkcs11"
    )
    archives = Path("/results/official")
    archives.mkdir(exist_ok=True)
    versions = command(
        "dpkg-query", "-W", "-f=${Package}=${Version}\n", "opensc", "opensc-pkcs11"
    ).splitlines()
    subprocess.run(["apt-get", "download", *versions], cwd=archives, check=True)
    official_root = Path("/tmp/official-archive")
    official_root.mkdir()
    for deb in archives.glob("*.deb"):
        subprocess.run(["dpkg-deb", "-x", str(deb), str(official_root)], check=True)
    original = inventory(
        official_root,
        [str(p.relative_to(official_root)) for p in official_root.rglob("*")],
    )
elif arch:
    original_version = command("pacman", "-Q", "opensc")
    original_paths = command("pacman", "-Qlq", "opensc").splitlines()
    original = {
        p: {"type": "symlink", "target": os.readlink(p)}
        if Path(p).is_symlink()
        else {"type": "file"}
        for p in original_paths
        if not p.endswith("/")
    }
else:
    names = [
        p
        for p in command("rpm", "-qa", "--qf", "%{NAME}\n").splitlines()
        if p in ("opensc", "opensc-libs")
    ]
    original_version = command("rpm", "-q", *names)
    original = {}
    records = command(
        "rpm",
        "-q",
        "--qf",
        "[%{FILENAMES}\t%{FILEMODES:octal}\t%{FILELINKTOS}\n]",
        *names,
    )
    for record in records.splitlines():
        path, mode, link = record.split("\t")
        mode = int(mode, 8)
        if stat.S_ISLNK(mode):
            original[path] = {"type": "symlink", "target": link}
        elif stat.S_ISREG(mode):
            original[path] = {"type": "file"}
root = Path("/tmp/opensc-archive")
root.mkdir()
if apt:
    subprocess.run(["dpkg-deb", "-x", artifact, str(root)], check=True)
elif arch:
    subprocess.run(["tar", "-xf", artifact, "-C", str(root)], check=True)
else:
    subprocess.run(
        [
            "bash",
            "-o",
            "pipefail",
            "-c",
            'rpm2cpio "$1" | cpio -idm --quiet',
            "extract",
            artifact,
        ],
        cwd=root,
        check=True,
    )
actual = inventory(root, [str(p.relative_to(root)) for p in root.rglob("*")])
# Pacman's archive bookkeeping is metadata, not installed package content.
actual = {
    p: v
    for p, v in actual.items()
    if p not in ("/.PKGINFO", "/.BUILDINFO", "/.MTREE", "/.INSTALL")
}
report = {
    "target": target,
    "artifact": Path(artifact).name,
    "official_version": original_version,
    "added": sorted(actual.keys() - original.keys()),
    "missing": sorted(original.keys() - actual.keys()),
    "changed_types_or_links": {
        p: {"official": original[p], "ours": actual[p]}
        for p in actual.keys() & original.keys()
        if original[p] != actual[p]
    },
    "official": original,
    "ours": actual,
}
# Shared-library SONAME changes follow the upstream ABI. Build-id links are
# compiler-generated metadata and cannot match the distribution's binaries.
abi = re.compile(
    r"/usr/lib(?:64|/(?:x86_64|aarch64)-linux-gnu)?/(?:libopensc|libsmm-local)\.so\.\d+(?:\.\d+\.\d+)?$"
)
removed_profiles = (
    {
        "/usr/share/opensc/" + name + ".profile"
        for name in ("gpk", "incrypto34", "jcop", "miocos", "westcos")
    }
    if target == "jammy"
    else set()
)
report["unexpected_added"] = [p for p in report["added"] if not abi.fullmatch(p)]
report["unexpected_missing"] = [
    p
    for p in report["missing"]
    if not abi.fullmatch(p)
    and not p.startswith("/usr/lib/.build-id/")
    and p not in removed_profiles
]
report["unexpected_links"] = {
    p: v
    for p, v in report["changed_types_or_links"].items()
    if not (
        p.endswith("/libsmm-local.so")
        and abi.fullmatch(str(Path(p).parent / v["ours"].get("target", "")))
        and abi.fullmatch(str(Path(p).parent / v["official"].get("target", "")))
    )
}
report["layout"] = (
    "passed"
    if not any(
        report[k]
        for k in ("unexpected_added", "unexpected_missing", "unexpected_links")
    )
    else "failed"
)
Path("/results/inventory.json").write_text(
    json.dumps(report, indent=2, sort_keys=True) + "\n"
)
if apt:
    install = ["apt-get", "install", "-y", artifact]
elif arch:
    if Path(artifact).name.startswith("opensc-git"):
        subprocess.run(["pacman", "-Rdd", "--noconfirm", "opensc"], check=True)
    install = ["pacman", "-U", "--noconfirm", artifact]
elif target.startswith("opensuse"):
    install = [
        "zypper",
        "--non-interactive",
        "install",
        "--allow-unsigned-rpm",
        "--force-resolution",
        artifact,
    ]
else:
    install = ["dnf", "install", "-y", "--allowerasing", artifact]
subprocess.run(
    install, check=True, env=dict(os.environ, DEBIAN_FRONTEND="noninteractive")
)
variant = "opensc-git" if Path(artifact).name.startswith("opensc-git") else "opensc"
if apt:
    expected_version = command("dpkg-deb", "-f", artifact, "Version").strip()
    installed_version = command("dpkg-query", "-W", "-f=${Version}", variant).strip()
elif arch:
    expected_version = command("pacman", "-Qp", artifact).strip()
    installed_version = command("pacman", "-Q", variant).strip()
else:
    expected_version = command(
        "rpm", "-qp", "--qf", "%{VERSION}-%{RELEASE}", artifact
    ).strip()
    installed_version = command(
        "rpm", "-q", "--qf", "%{VERSION}-%{RELEASE}", variant
    ).strip()
assert installed_version == expected_version, (installed_version, expected_version)
report["installed_version"] = installed_version
subprocess.run(["opensc-tool", "--version"], check=True)
module = next(
    p for p in actual if p.endswith("/opensc-pkcs11.so") and "/pkcs11/" not in p
)
library = ctypes.CDLL(module)
for name in ("C_Initialize", "C_Finalize"):
    function = getattr(library, name)
    function.argtypes = [ctypes.c_void_p]
    function.restype = ctypes.c_ulong
    assert function(None) == 0, name
modules = command("p11-kit", "list-modules")
assert "opensc" in modules.lower(), modules
config = "/etc/opensc/opensc.conf" if apt else "/etc/opensc.conf"
assert Path(config).is_file(), config
report["installation"] = "passed"
report["pkcs11"] = "passed"
Path("/results/inventory.json").write_text(
    json.dumps(report, indent=2, sort_keys=True) + "\n"
)
print("Installation and PKCS#11 OK; layout:", report["layout"])
assert report["layout"] == "passed", {
    k: report[k] for k in ("unexpected_added", "unexpected_missing", "unexpected_links")
}
