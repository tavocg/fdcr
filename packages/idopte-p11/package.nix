{
  lib,
  stdenv,
  callPackage,
  patchelf,
  ubuntuRelease ? "noble",
}:
let
  source = (callPackage ../../artifacts/artifacts.nix { }).${ubuntuRelease};
in
stdenv.mkDerivation {
  pname = "idopte-p11";
  version = "6.23.50.5";

  src = source.idopte;

  nativeBuildInputs = [ patchelf ];
  dontUnpack = true;
  dontFixup = true;

  buildPhase = ''
    runHook preBuild
    cp -a "$src" extracted
    chmod -R u+w extracted

    # The vendor libraries depend on neighboring files in SCMiddleware.
    # Search beside the ELF (Nix) and in the installed system directory.
    for elf in extracted/usr/lib/SCMiddleware/*; do
      old_runpath="$(patchelf --print-rpath "$elf" 2>/dev/null)" || continue
      case "$old_runpath" in
        *\$ORIGIN*) new_runpath="$old_runpath:/usr/lib/SCMiddleware" ;;
        *) new_runpath='$ORIGIN:/usr/lib/SCMiddleware' ;;
      esac
      patchelf --set-rpath "$new_runpath" "$elf"
    done
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm644 extracted/etc/idoss.lic "$out/etc/idoss.lic"
    install -Dm644 extracted/etc/idoss.conf "$out/etc/idoss.conf"
    install -Dm755 extracted/usr/lib/SCMiddleware/idocachesrv \
      "$out/usr/lib/SCMiddleware/idocachesrv"
    for library in \
      legacy.so \
      libidop11.so \
      libidolog.so \
      libt_ias.so \
      libpodofo.so \
      libcrypto.so.3 \
      libssl.so.3 \
      libbz2.so \
      libbrotlicommon.so \
      libbrotlidec.so \
      libexpat.so \
      libfontconfig.so \
      libfreetype.so \
      libpng16.so \
      libxmlsec1.so \
      libxmlsec1-openssl.so \
      libdigidoc.so \
    ; do
      install -Dm644 "extracted/usr/lib/SCMiddleware/$library" \
        "$out/usr/lib/SCMiddleware/$library"
    done
    install -Dm644 ${./idocachesrv.service} \
      "$out/usr/lib/systemd/system/idocachesrv.service"
    install -d "$out/usr/lib/systemd/system/sockets.target.wants"
    ln -s /usr/lib/systemd/system/pcscd.socket \
      "$out/usr/lib/systemd/system/sockets.target.wants/pcscd.socket"
    for resource in \
      appIcon.png \
      application.png \
      branding.bin \
      checkBanner.png \
      checkIcon.png \
      crossBanner.png \
      crossIcon.png \
      loadIcon.png \
      tokmgr.bin \
      xsd.bin \
    ; do
      install -Dm644 "extracted/usr/share/SCMiddleware/$resource" \
        "$out/usr/share/SCMiddleware/$resource"
    done
    runHook postInstall
  '';

  meta = {
    description = "Idopte smart card middleware for Costa Rican digital signatures";
    homepage = "https://firmador.libre.cr/";
    license = lib.licenses.unfreeRedistributable;
    platforms = import ./systems.nix;
    mainProgram = "idocachesrv";
  };
}
