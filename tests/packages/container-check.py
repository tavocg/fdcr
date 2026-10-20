"""Install and remove both application stacks with real package-manager hooks."""

import json
import os
import ssl
import subprocess
import sys
from pathlib import Path


def run(*args):
    print("+", *args, flush=True)
    return subprocess.check_output(args, text=True, stderr=subprocess.STDOUT)


target = sys.argv[1]
packages = json.loads(Path("/artifacts/packages.json").read_text())
apt = target in (
    "jammy",
    "noble",
    "debian13",
    "ubuntu2604",
    "linuxmint223",
    "linuxmint7",
)
arch = target == "arch"
suse = target.startswith("opensuse")
os.environ["DEBIAN_FRONTEND"] = "noninteractive"
report = {
    "target": target,
    "os_release": Path("/etc/os-release").read_text(),
    "cases": [],
    "passed": False,
}
if Path("/etc/linuxmint/info").exists():
    report["mint_info"] = Path("/etc/linuxmint/info").read_text()
try:
    if apt:
        print(run("apt-get", "update"), flush=True)
    elif arch:
        print(run("pacman", "-Syu", "--noconfirm"), flush=True)
    elif suse:
        print(
            run("zypper", "--non-interactive", "--gpg-auto-import-keys", "refresh"),
            flush=True,
        )
    for variant in ("stable", "git"):
        names = [
            "bccr-certs",
            "bccr-gaudi",
            "opensc" + ("-git" if variant == "git" else ""),
            "firmador" + ("-git" if variant == "git" else ""),
        ]
        paths = ["/artifacts/" + packages[n] for n in names]
        case = {
            "variant": variant,
            "packages": names,
            "installation": False,
            "removal": False,
        }
        report["cases"].append(case)
        if apt:
            output = run("apt-get", "install", "-y", *paths)
        elif arch:
            # Replace vanilla OpenSC before installing its differently named variant.
            if (
                variant == "git"
                and subprocess.run(
                    ["pacman", "-Q", "opensc"], stdout=subprocess.DEVNULL, check=False
                ).returncode
                == 0
            ):
                print(run("pacman", "-Rns", "--noconfirm", "opensc"), flush=True)
            output = run("pacman", "-U", "--noconfirm", *paths)
        elif suse:
            output = run(
                "zypper",
                "--non-interactive",
                "install",
                "--allow-unsigned-rpm",
                "--force-resolution",
                *paths,
            )
        else:
            output = run("dnf", "install", "-y", "--allowerasing", *paths)
        print(output, flush=True)
        owned = {}
        for name in names:
            if apt:
                assert (
                    run("dpkg-query", "-W", "-f=${Status}", name).strip()
                    == "install ok installed"
                )
                assert (
                    run("dpkg-query", "-W", "-f=${Version}", name).strip()
                    == run(
                        "dpkg-deb", "-f", "/artifacts/" + packages[name], "Version"
                    ).strip()
                )
                files = run("dpkg-query", "-L", name).splitlines()
            elif arch:
                assert (
                    run("pacman", "-Q", name).strip()
                    == run("pacman", "-Qp", "/artifacts/" + packages[name]).strip()
                )
                files = run("pacman", "-Qlq", name).splitlines()
            else:
                assert run("rpm", "-q", "--qf", "%{VERSION}-%{RELEASE}", name) == run(
                    "rpm",
                    "-qp",
                    "--qf",
                    "%{VERSION}-%{RELEASE}",
                    "/artifacts/" + packages[name],
                )
                files = run("rpm", "-ql", name).splitlines()
            owned[name] = [
                p for p in files if Path(p).is_file() or Path(p).is_symlink()
            ]
            assert owned[name], name
        for p in [
            "/opt/Agente-GAUDI/bin/Agente-GAUDI",
            "/etc/xdg/autostart/Agente-GAUDI.desktop",
            "/usr/share/bccr-certs/pem/roots.pem",
            "/usr/bin/" + names[-1],
        ]:
            assert Path(p).is_file(), p
        print(run("opensc-tool", "--version"), flush=True)
        # Fedora splits generated trust bundles by purpose (TLS, mail, code signing).
        # Its directory store is loaded lazily by OpenSSL, so inspect those bundles explicitly.
        bundles = list(Path("/etc/pki/ca-trust/extracted/pem").glob("*-ca-bundle.pem"))
        bundles += [
            p
            for p in (
                Path("/etc/ssl/certs/ca-certificates.crt"),
                Path("/etc/ssl/ca-bundle.pem"),
                Path("/var/lib/ca-certificates/ca-bundle.pem"),
                Path("/etc/ca-certificates/extracted/tls-ca-bundle.pem"),
            )
            if p.is_file()
        ]
        trusted = set()
        if bundles:
            for bundle in bundles:
                trusted.update(
                    ssl.create_default_context(cafile=str(bundle)).get_ca_certs(
                        binary_form=True
                    )
                )
        else:
            trusted.update(ssl.create_default_context().get_ca_certs(binary_form=True))
        roots = {
            ssl.PEM_cert_to_DER_cert(p.read_text())
            for p in Path("/usr/share/bccr-certs/pem/roots").glob("*.crt")
        }
        assert roots and roots <= trusted, "BCCR roots missing from system trust store"
        case["trust_store"] = True
        case["installation"] = True
        if apt:
            output = run("apt-get", "purge", "-y", *reversed(names))
        elif arch:
            output = run("pacman", "-R", "--noconfirm", *reversed(names))
        elif suse:
            output = run("zypper", "--non-interactive", "remove", *reversed(names))
        else:
            output = run("dnf", "remove", "-y", *reversed(names))
        print(output, flush=True)
        leftovers = {
            n: [p for p in files if Path(p).exists() or Path(p).is_symlink()]
            for n, files in owned.items()
        }
        assert not any(leftovers.values()), leftovers
        for name in names:
            if apt:
                status = subprocess.run(
                    ["dpkg-query", "-W", "-f=${Status}", name],
                    capture_output=True,
                    text=True,
                    check=False,
                )
                assert status.returncode != 0 or "installed" not in status.stdout, (
                    name,
                    status.stdout,
                )
            else:
                query = ["pacman", "-Q", name] if arch else ["rpm", "-q", name]
                assert (
                    subprocess.run(
                        query, stdout=subprocess.DEVNULL, check=False
                    ).returncode
                    != 0
                ), name
        case["removal"] = True
    report["passed"] = True
except Exception as error:
    if isinstance(error, subprocess.CalledProcessError):
        print(error.output, flush=True)
    report["error"] = str(error)
    raise
finally:
    Path("/results/result.json").write_text(json.dumps(report, indent=2) + "\n")
