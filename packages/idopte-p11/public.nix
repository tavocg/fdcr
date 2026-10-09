{
  lib,
  metarepo,
  package,
}:
let
  common = {
    payload = package;
    name = package.pname;
    version = package.version;
    release = "1";
    maintainer = "Idopte <support@idopte.fr>";
    inherit (package.meta) description homepage;
    license = "LicenseRef-Proprietary";
  };
  builders = {
    deb = metarepo.mkApt;
    dnf = metarepo.mkDnf;
    pacman = metarepo.mkPacman;
  };
  dependencies = {
    deb = [
      "libc6 (>= 2.38)"
      "libstdc++6 (>= 13.2)"
      "libgcc-s1"
      "libpcsclite1 (>= 1.7)"
      "libxml2 (>= 2.7.3)"
      "zlib1g (>= 1:1.2.3.4)"
      "pcscd"
      "libccid"
      "init-system-helpers"
    ];
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
  packages = lib.mapAttrs (
    format: builder:
    builder (common // {
      architecture = if format == "deb" then "amd64" else "x86_64";
      depends = dependencies.${format};
    })
  ) builders;
in
{
  channels = {
    noble = packages.deb;
    fedora = packages.dnf;
    arch = packages.pacman;
  };
}
