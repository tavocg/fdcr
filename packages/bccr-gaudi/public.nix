{
  lib,
  metarepo,
  package,
  buildFHSEnv,
  stdenvNoCC,
  dpkg,
  unzip,
}:
let
  jammyPackage = import ./package.nix {
    inherit lib buildFHSEnv stdenvNoCC dpkg unzip;
    ubuntuRelease = "jammy";
  };
  common = payload: {
    inherit payload;
    name = package.pname;
    version = package.version;
    release = package.passthru.release;
    maintainer = "Banco Central de Costa Rica";
    inherit (package.meta) description homepage;
    license = "LicenseRef-Proprietary";
  };
  dependencies = {
    jammy = [
      "libc6" "libstdc++6" "libgcc-s1" "libasound2" "libatk1.0-0"
      "libcairo2" "libdbus-1-3" "libfontconfig1" "libfreetype6"
      "libgdk-pixbuf-2.0-0" "libglib2.0-0" "libgtk-3-0"
      "libpango-1.0-0" "libpangocairo-1.0-0" "libpcsclite1" "libx11-6"
      "libxext6" "libxi6" "libxrender1" "libxtst6" "libxxf86vm1"
      "libgl1" "pcscd" "xdg-utils" "zlib1g"
    ];
    noble = [
      "libc6" "libstdc++6" "libgcc-s1" "libasound2t64" "libatk1.0-0t64"
      "libcairo2" "libdbus-1-3" "libfontconfig1" "libfreetype6"
      "libgdk-pixbuf-2.0-0" "libglib2.0-0t64" "libgtk-3-0t64"
      "libpango-1.0-0" "libpangocairo-1.0-0" "libpcsclite1" "libx11-6"
      "libxext6" "libxi6" "libxrender1" "libxtst6" "libxxf86vm1"
      "libgl1" "pcscd" "xdg-utils" "zlib1g"
    ];
  };
in
{
  channels = {
    jammy = metarepo.mkApt ((common jammyPackage.passthru.payload) // {
      architecture = "amd64";
      depends = dependencies.jammy;
    });
    noble = metarepo.mkApt ((common package.passthru.payload) // {
      architecture = "amd64";
      depends = dependencies.noble;
    });
    fedora = metarepo.mkDnf ((common package.passthru.payload) // {
      architecture = "x86_64";
      depends = [
        "alsa-lib" "atk" "cairo" "fontconfig" "freetype" "glibc"
        "gdk-pixbuf2" "glib2" "gtk2" "gtk3" "libX11" "libXext"
        "libXi" "libXrender" "libXtst" "libXxf86vm" "mesa-libGL"
        "libgcc" "libstdc++" "pango" "pcsc-lite" "pcsc-lite-libs"
        "xdg-utils" "zlib"
      ];
    });
    arch = metarepo.mkPacman ((common package.passthru.payload) // {
      architecture = "x86_64";
      depends = [
        "alsa-lib" "at-spi2-core" "cairo" "fontconfig" "freetype2"
        "gcc-libs" "gdk-pixbuf2" "glib2" "glibc" "gtk3" "libx11"
        "libxext" "libxi" "libxrender" "libxtst" "libxxf86vm" "mesa"
        "pango" "pcsclite" "xdg-utils" "zlib"
      ];
    });
  };
}
