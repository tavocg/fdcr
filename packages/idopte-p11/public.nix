{
  lib,
  metarepo,
  package,
  stdenv,
  dpkg,
  unzip,
  patchelf,
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
    inherit lib stdenv dpkg unzip patchelf;
    ubuntuRelease = "jammy";
  };
  apt = payload: depends: metarepo.mkApt ((common payload) // {
    architecture = "amd64";
    inherit depends;
  });
  nativeCommon = common package;
  builders = {
    dnf = metarepo.mkDnf;
    pacman = metarepo.mkPacman;
  };
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
  nativePackages = lib.mapAttrs (
    format: builder:
    builder (nativeCommon // {
      architecture = "x86_64";
      depends = nativeDependencies.${format};
    })
  ) builders;
in
{
  channels = {
    fedora = nativePackages.dnf;
    arch = nativePackages.pacman;
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
