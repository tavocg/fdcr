{
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

  dnf = [
    "alsa-lib" "atk" "cairo" "fontconfig" "freetype" "glibc"
    "gdk-pixbuf2" "glib2" "gtk2" "gtk3" "libX11" "libXext"
    "libXi" "libXrender" "libXtst" "libXxf86vm" "mesa-libGL"
    "libgcc" "libstdc++" "pango" "pcsc-lite" "pcsc-lite-libs"
    "xdg-utils" "zlib"
  ];
  pacman = [
    "alsa-lib" "at-spi2-core" "cairo" "fontconfig" "freetype2"
    "gcc-libs" "gdk-pixbuf2" "glib2" "glibc" "gtk3" "libx11"
    "libxext" "libxi" "libxrender" "libxtst" "libxxf86vm" "mesa"
    "pango" "pcsclite" "xdg-utils" "zlib"
  ];
}
