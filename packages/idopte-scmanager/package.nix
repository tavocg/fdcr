{ lib, stdenv, callPackage, unzip, patchelf, ubuntuRelease ? "noble" }:
let
  source = (callPackage ../../artifacts/artifacts.nix { }).${ubuntuRelease};
in
stdenv.mkDerivation {
  pname = "idopte-scmanager";
  version = "6.23.50.5";

  src = source.idopte;

  nativeBuildInputs = [ unzip patchelf ];
  dontUnpack = true;
  dontFixup = true;

  buildPhase = ''
    runHook preBuild
    cp -a "$src" extracted
    chmod -R u+w extracted
    unzip -q extracted/usr/share/SCMiddleware/xsd.bin \
      -d extracted/usr/share/SCMiddleware/shema

    # SCManager loads vendor libraries from the adjacent SCMiddleware directory.
    # The packaged binary's absolute RUNPATH does not resolve them in the Nix
    # package layout, so keep the adjacent lookup and add the system install path.
    manager=extracted/usr/lib/SCMiddleware/SCManager
    old_runpath="$(patchelf --print-rpath "$manager" 2>/dev/null || true)"
    case ":$old_runpath:" in
      *:\$ORIGIN:*) new_runpath="$old_runpath" ;;
      *) new_runpath="''${old_runpath:+$old_runpath:}\$ORIGIN" ;;
    esac
    case ":$new_runpath:" in
      *:/usr/lib/SCMiddleware:*) ;;
      *) new_runpath="''${new_runpath:+$new_runpath:}/usr/lib/SCMiddleware" ;;
    esac
    patchelf --set-rpath "$new_runpath" "$manager"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 extracted/usr/lib/SCMiddleware/SCManager \
      "$out/usr/lib/SCMiddleware/SCManager"
    install -Dm644 extracted/usr/share/SCMiddleware/crypto_common.py \
      "$out/usr/share/SCMiddleware/crypto_common.py"
    install -Dm644 extracted/usr/share/SCMiddleware/open_pkcs7.py \
      "$out/usr/share/SCMiddleware/open_pkcs7.py"
    cp -a extracted/usr/share/SCMiddleware/shema "$out/usr/share/SCMiddleware/shema"
    cp -a extracted/usr/share/applications "$out/usr/share/applications"
    cp -a extracted/usr/share/mime "$out/usr/share/mime"
    cp -a extracted/usr/share/nautilus-python "$out/usr/share/nautilus-python"

    install -d "$out/etc/xdg/autostart"
    cat > "$out/usr/share/applications/SCManager.desktop" <<'EOF'
    [Desktop Entry]
    Type=Application
    Name=SCManager
    Comment=Administrador de tarjetas Idopte
    Exec=/usr/lib/SCMiddleware/SCManager
    Icon=/usr/share/SCMiddleware/application.png
    StartupWMClass=SCManager
    Terminal=false
    Categories=Utility;Security;
    EOF
    install -m644 "$out/usr/share/applications/SCManager.desktop" \
      "$out/etc/xdg/autostart/SCManager.desktop"
    runHook postInstall
  '';

  meta = {
    description = "Idopte smart card manager and desktop integration";
    homepage = "https://firmador.libre.cr/";
    license = lib.licenses.unfreeRedistributable;
    platforms = import ../idopte-p11/systems.nix;
  };
}
