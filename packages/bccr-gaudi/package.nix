{
  lib,
  buildFHSEnv,
  stdenvNoCC,
  dpkg,
  unzip,
  ubuntuRelease ? "noble",
}:
let
  sources = {
    noble = {
      zip = ../idopte-p11/artifacts/sfd_ClientesLinux_DEB64_Ubuntu24_rev26_08.zip;
      md5 = "7e5c2772f958a9fd855d41d7d5c26a52";
      debPath = "sfd_ClientesLinux_DEB64_Ubuntu24_26_08/Firma Digital/Agente GAUDI/agente-gaudi_29.0_amd64.deb";
    };
    jammy = {
      zip = ../idopte-p11/artifacts/sfd_ClientesLinux_DEB64_Ubuntu22_rev26_08.zip;
      md5 = "348e3c06ef5218542266bdf417c13e36";
      debPath = "sfd_ClientesLinux_DEB64_Ubuntu22_26_08/Firma Digital/Agente GAUDI/agente-gaudi_29.0_amd64.deb";
    };
  };
  source = sources.${ubuntuRelease};
  payload = stdenvNoCC.mkDerivation {
    pname = "bccr-gaudi-payload";
    version = "29.0-1";
    src = source.zip;
    nativeBuildInputs = [ dpkg unzip ];
    dontUnpack = true;
    dontFixup = true;
    buildPhase = ''
      runHook preBuild
      printf '%s  %s\n' '${source.md5}' "$src" | md5sum --check --status || {
        echo "Source ZIP MD5 mismatch" >&2
        exit 1
      }
      mkdir -p source
      unzip -p "$src" '${source.debPath}' > source/bccr-gaudi.deb
      dpkg-deb --extract source/bccr-gaudi.deb extracted
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/opt" "$out/usr/share/applications" \
        "$out/usr/share/licenses/bccr-gaudi" "$out/etc/xdg/autostart"
      cp -a extracted/opt "$out/"
      install -m644 extracted/opt/Agente-GAUDI/lib/Agente-GAUDI.desktop \
        "$out/usr/share/applications/Agente-GAUDI.desktop"
      install -m644 extracted/opt/Agente-GAUDI/lib/Agente-GAUDI.desktop \
        "$out/etc/xdg/autostart/Agente-GAUDI.desktop"
      install -m644 extracted/opt/Agente-GAUDI/lib/app/licence.md \
        "$out/usr/share/licenses/bccr-gaudi/licence.md"
      runHook postInstall
    '';
  };
in
buildFHSEnv {
  pname = "bccr-gaudi";
  version = "29.0";
  executableName = "agente-gaudi";
  targetPkgs = pkgs: [
    pkgs.bash
    pkgs.coreutils
    pkgs.xdg-utils
    pkgs.cacert
    pkgs.stdenv.cc.cc.lib
    pkgs.zlib
    pkgs.glib
    pkgs.gtk2
    pkgs.gtk3
    pkgs.atk
    pkgs.cairo
    pkgs.pango
    pkgs.gdk-pixbuf
    pkgs.fontconfig
    pkgs.freetype
    pkgs.alsa-lib
    pkgs.libGL
    pkgs.libX11
    pkgs.libXext
    pkgs.libXi
    pkgs.libXrender
    pkgs.libXtst
    pkgs.libXxf86vm
    pkgs.pcsclite
    pkgs.dbus
    pkgs.systemd
  ];
  multiPkgs = null;
  extraBuildCommands = ''
    mkdir -p "$out/opt/Agente-GAUDI"
  '';
  extraBwrapArgs = [ "--ro-bind ${payload}/opt/Agente-GAUDI /opt/Agente-GAUDI" ];
  runScript = "/opt/Agente-GAUDI/bin/Agente-GAUDI";
  extraInstallCommands = ''
    mkdir -p "$out/share/applications" "$out/share/icons/hicolor/128x128/apps" "$out/etc/xdg/autostart" "$out/share/licenses/Agente-GAUDI-29.0"
    cp ${payload}/usr/share/applications/Agente-GAUDI.desktop "$out/share/applications/"
    cp ${payload}/etc/xdg/autostart/Agente-GAUDI.desktop "$out/etc/xdg/autostart/"
    cp ${payload}/usr/share/licenses/bccr-gaudi/licence.md "$out/share/licenses/Agente-GAUDI-29.0/licence.md"
    cp ${payload}/opt/Agente-GAUDI/lib/Agente-GAUDI.png "$out/share/icons/hicolor/128x128/apps/agente-gaudi.png"
    substituteInPlace "$out/share/applications/Agente-GAUDI.desktop" \
      "$out/etc/xdg/autostart/Agente-GAUDI.desktop" \
      --replace-fail 'Version=29.0' 'Version=1.0' \
      --replace-fail /opt/Agente-GAUDI/bin/Agente-GAUDI "$out/bin/agente-gaudi" \
      --replace-fail /opt/Agente-GAUDI/lib/Agente-GAUDI.png agente-gaudi
  '';
  passthru = {
    inherit payload;
    release = "1";
    packageArchitectures = {
      dnf = "x86_64";
      pacman = "x86_64";
    };
  };
  meta = {
    description = "Agente GAUDI del Banco Central de Costa Rica";
    homepage = "https://www.soportefirmadigital.com/";
    license = lib.licenses.unfree;
    platforms = import ./systems.nix;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "agente-gaudi";
  };
}
