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
      "libc6 (>= 2.15)"
      "libgcc1 (>= 1:4.6)"
      "libstdc++6 (>= 4.6)"
      "libpcsclite1 (>= 1.7)"
      "pcscd"
    ];
    dnf = [
      "glibc"
      "libgcc"
      "libstdc++"
      "pcsc-lite-libs"
      "pcsc-lite"
    ];
    pacman = [
      "glibc"
      "gcc-libs"
      "pcsclite"
    ];
  };
  packages = lib.mapAttrs (
    format: builder:
    builder (common // {
      architecture = "x86_64";
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
