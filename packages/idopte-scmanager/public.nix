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
      "sysvinit-utils"
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
      "initscripts"
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
      "glib2"
      "gtk3"
      "webkit2gtk"
      "libnotify"
      "libappindicator-gtk3"
      "lsof"
      "procps-ng"
      "sysvinit"
      "python"
      "python-requests"
      "zenity"
      "xdg-utils"
      "xdg-user-dirs"
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
