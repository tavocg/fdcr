{
  lib,
  metarepo,
  package,
  stdenv,
  callPackage,
  patchelf,
  runCommand,
}:
let
  common = payload: {
    inherit payload;
    name = payload.pname;
    version = payload.version;
    release = "1";
    maintainer = "Idopte <support@idopte.fr>";
    inherit (payload.meta) description homepage;
    license = "LicenseRef-Proprietary";
  };
  jammyPackage = import ./package.nix {
    inherit lib stdenv callPackage patchelf;
    ubuntuRelease = "jammy";
  };
  apt = payload: depends: metarepo.mkApt ((common payload) // {
    architecture = "amd64";
    inherit depends;
  });
  nativeCommon = common package;
  archPayload = runCommand "idopte-p11-arch-payload" { } ''
    cp -a ${package}/. "$out/"
    chmod -R u+w "$out"
    mkdir -p "$out/usr/share/libalpm/hooks"
    cat > "$out/usr/share/libalpm/hooks/90-idopte-pcscd.hook" <<'EOF'
    [Trigger]
    Operation = Install
    Operation = Upgrade
    Type = Package
    Target = idopte-p11

    [Action]
    Description = Starting PC/SC socket for Idopte...
    When = PostTransaction
    Exec = /usr/bin/sh -c 'if [ -d /run/systemd/system ]; then /usr/bin/systemctl daemon-reload && /usr/bin/systemctl start pcscd.socket; fi'
    EOF
  '';
  nativeDependencies = {
    dnf = [
      "glibc"
      "libgcc"
      "libstdc++"
      "pcsc-lite-libs"
      "pcsc-lite"
      "libxml2"
      "zlib"
      "pcsc-lite-ccid"
    ];
    pacman = [
      "glibc"
      "gcc-libs"
      "pcsclite"
      "libxml2"
      "zlib"
      "ccid"
    ];
  };
  dnf = metarepo.mkDnf (nativeCommon // {
    architecture = "x86_64";
    depends = nativeDependencies.dnf;
  });
  pacman = metarepo.mkPacman (nativeCommon // {
    payload = archPayload;
    architecture = "x86_64";
    depends = nativeDependencies.pacman;
  });
in
{
  channels = {
    fedora = dnf;
    arch = pacman;
    noble = apt package [
      "libc6 (>= 2.38)"
      "libstdc++6 (>= 13.2)"
      "libgcc-s1"
      "libpcsclite1 (>= 1.7)"
      "libxml2 (>= 2.7.3)"
      "zlib1g (>= 1:1.2.3.4)"
      "pcscd"
      "libccid"
    ];
    jammy = apt jammyPackage [
      "libc6 (>= 2.15)"
      "libgcc1 (>= 1:4.6)"
      "libstdc++6 (>= 4.6)"
      "libpcsclite1 (>= 1.7)"
      "libxml2 (>= 2.7.3)"
      "zlib1g (>= 1:1.2.3.4)"
      "pcscd"
      "libccid"
    ];
  };
}
