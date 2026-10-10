{
  lib,
  buildFHSEnv,
  stdenvNoCC,
  callPackage,
  ubuntuRelease ? "noble",
}:
let
  source = (callPackage ../../artifacts/artifacts.nix { }).${ubuntuRelease};
  desktopName = "bccr.principal.InicializadorDeActualizacion.desktop";
  payload = stdenvNoCC.mkDerivation {
    pname = "bccr-gaudi-payload";
    version = "29.0-1";
    src = source.gaudi;
    dontUnpack = true;
    dontFixup = true;
    buildPhase = ''
      runHook preBuild
      cp -a "$src" extracted
      chmod -R u+w extracted
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/opt" "$out/usr/share/applications" \
        "$out/usr/share/licenses/bccr-gaudi" "$out/etc/xdg/autostart"
      cp -a extracted/opt "$out/"
      # The optional .desktop Version describes the desktop entry format,
      # not GAUDI's version. Omit the vendor's application version here.
      sed -i '/^Version=/d' "$out/opt/Agente-GAUDI/lib/Agente-GAUDI.desktop"
      # GNOME matches AWT through StartupWMClass and JavaFX through desktopName.
      sed -i '/^StartupWMClass=/d' "$out/opt/Agente-GAUDI/lib/Agente-GAUDI.desktop"
      printf '\nStartupWMClass=Agente GAUDI\n' \
        >> "$out/opt/Agente-GAUDI/lib/Agente-GAUDI.desktop"
      install -m644 "$out/opt/Agente-GAUDI/lib/Agente-GAUDI.desktop" \
        "$out/usr/share/applications/${desktopName}"
      # Keep the autostart filename stable to preserve user overrides.
      install -m644 "$out/opt/Agente-GAUDI/lib/Agente-GAUDI.desktop" \
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
    cp ${payload}/usr/share/applications/${desktopName} "$out/share/applications/"
    cp ${payload}/etc/xdg/autostart/Agente-GAUDI.desktop "$out/etc/xdg/autostart/"
    cp ${payload}/usr/share/licenses/bccr-gaudi/licence.md "$out/share/licenses/Agente-GAUDI-29.0/licence.md"
    cp ${payload}/opt/Agente-GAUDI/lib/Agente-GAUDI.png "$out/share/icons/hicolor/128x128/apps/agente-gaudi.png"
    substituteInPlace "$out/share/applications/${desktopName}" \
      "$out/etc/xdg/autostart/Agente-GAUDI.desktop" \
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
