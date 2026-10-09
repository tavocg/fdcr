{
  lib,
  metarepo,
  package,
  stdenv,
  callPackage,
  unzip,
  patchelf,
}:
let
  jammyPackage = import ./package.nix {
    inherit lib stdenv callPackage unzip patchelf;
    ubuntuRelease = "jammy";
  };
  common = payload: {
    inherit payload;
    name = payload.pname;
    version = payload.version;
    release = "1";
    maintainer = "Idopte <support@idopte.fr>";
    inherit (payload.meta) description homepage;
    license = "LicenseRef-Proprietary";
  };
  dependencies = {
    jammy = [
      "idopte-p11 (= 6.23.50.5-1)"
      "libc6 (>= 2.34)"
      "libstdc++6 (>= 12)"
      "libgcc-s1"
      "libpcsclite1 (>= 1.7)"
      "libglib2.0-0"
      "libgtk-3-0"
      "libwebkit2gtk-4.0-37"
      "libjavascriptcoregtk-4.0-18"
      "libnotify4"
      "libappindicator3-1"
      "lsof"
      "procps"
      "python3"
      "python3-requests"
      "zenity"
      "xdg-utils"
      "xdg-user-dirs"
    ];
    noble = [
      "idopte-p11 (= 6.23.50.5-1)"
      "libc6 (>= 2.38)"
      "libstdc++6 (>= 13.2)"
      "libgcc-s1"
      "libpcsclite1 (>= 1.7)"
      "libglib2.0-0t64"
      "libgtk-3-0t64"
      "libwebkit2gtk-4.1-0"
      "libjavascriptcoregtk-4.1-0"
      "libnotify4"
      "libappindicator3-1"
      "lsof"
      "procps"
      "python3"
      "python3-requests"
      "zenity"
      "xdg-utils"
      "xdg-user-dirs"
    ];
    dnf = [
      "idopte-p11 = 6.23.50.5-1"
      "glibc"
      "libstdc++"
      "libgcc"
      "pcsc-lite-libs"
      "glib2"
      "gtk3"
      "webkit2gtk4.1"
      "libnotify"
      "libappindicator-gtk3"
      "lsof"
      "procps-ng"
      "python3"
      "python3-requests"
      "zenity"
      "xdg-utils"
      "xdg-user-dirs"
    ];
    pacman = [
      "idopte-p11=6.23.50.5-1"
      "glibc"
      "gcc-libs"
      "pcsclite"
      "libxml2-legacy"
      "glib2"
      "gtk3"
      "webkit2gtk-4.1"
      "libnotify"
      "libappindicator-gtk3"
      "lsof"
      "procps-ng"
      "python"
      "python-requests"
      "zenity"
      "xdg-utils"
      "xdg-user-dirs"
    ];
  };
  apt = payload: depends: metarepo.mkApt ((common payload) // {
    architecture = "amd64";
    inherit depends;
  });
  nativeCommon = common package;
  dnf = metarepo.mkDnf (nativeCommon // {
    architecture = "x86_64";
    depends = dependencies.dnf;
  });
  pacman = metarepo.mkPacman (nativeCommon // {
    architecture = "x86_64";
    depends = dependencies.pacman;
  });
in
{
  channels = {
    jammy = apt jammyPackage dependencies.jammy;
    noble = apt package dependencies.noble;
    fedora = dnf;
    arch = pacman;
  };
}
