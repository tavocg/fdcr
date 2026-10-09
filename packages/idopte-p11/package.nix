{
  lib,
  stdenv,
  dpkg,
  unzip,
  patchelf,
  ubuntuRelease ? "noble",
}:
let
  sources = {
    noble = {
      zip = ./artifacts/sfd_ClientesLinux_DEB64_Ubuntu24_rev26_08.zip;
      md5 = "7e5c2772f958a9fd855d41d7d5c26a52";
      debPath = "sfd_ClientesLinux_DEB64_Ubuntu24_26_08/Firma Digital/Idopte/Idopte_6.23.50.5_ubun24_amd64.deb";
    };
    jammy = {
      zip = ./artifacts/sfd_ClientesLinux_DEB64_Ubuntu22_rev26_08.zip;
      md5 = "348e3c06ef5218542266bdf417c13e36";
      debPath = "sfd_ClientesLinux_DEB64_Ubuntu22_26_08/Firma Digital/Idopte/Idopte_6.23.50.5_ubun22_amd64.deb";
    };
  };
  source = sources.${ubuntuRelease};
in
stdenv.mkDerivation {
  pname = "idopte-p11";
  version = "6.23.50.5";

  src = source.zip;

  nativeBuildInputs = [ dpkg unzip patchelf ];
  dontUnpack = true;
  dontFixup = true;

  buildPhase = ''
    runHook preBuild
    printf '%s  %s\n' '${source.md5}' "$src" \
      | md5sum --check --status || {
        echo "Source ZIP MD5 mismatch" >&2
        exit 1
      }

    mkdir -p source
    unzip -p "$src" '${source.debPath}' > source/idopte.deb
    dpkg-deb --extract source/idopte.deb extracted

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
    install -Dm755 extracted/etc/init.d/idocachesrv "$out/etc/init.d/idocachesrv"
    install -Dm755 extracted/usr/lib/SCMiddleware/idocachesrv \
      "$out/usr/lib/SCMiddleware/idocachesrv"
    install -Dm644 extracted/usr/lib/SCMiddleware/legacy.so \
      "$out/usr/lib/SCMiddleware/legacy.so"
    install -Dm644 extracted/usr/lib/SCMiddleware/libidop11.so \
      "$out/usr/lib/SCMiddleware/libidop11.so"
    install -Dm644 extracted/usr/lib/SCMiddleware/libidolog.so \
      "$out/usr/lib/SCMiddleware/libidolog.so"
    install -Dm644 extracted/usr/lib/SCMiddleware/libt_ias.so \
      "$out/usr/lib/SCMiddleware/libt_ias.so"
    install -Dm644 extracted/usr/lib/SCMiddleware/libpodofo.so \
      "$out/usr/lib/SCMiddleware/libpodofo.so"
    install -Dm644 extracted/usr/lib/SCMiddleware/libcrypto.so.3 \
      "$out/usr/lib/SCMiddleware/libcrypto.so.3"
    install -Dm644 extracted/usr/lib/SCMiddleware/libssl.so.3 \
      "$out/usr/lib/SCMiddleware/libssl.so.3"
    install -Dm644 extracted/usr/lib/SCMiddleware/libbz2.so \
      "$out/usr/lib/SCMiddleware/libbz2.so"
    install -Dm644 extracted/usr/lib/SCMiddleware/libbrotlicommon.so \
      "$out/usr/lib/SCMiddleware/libbrotlicommon.so"
    install -Dm644 extracted/usr/lib/SCMiddleware/libbrotlidec.so \
      "$out/usr/lib/SCMiddleware/libbrotlidec.so"
    install -Dm644 extracted/usr/lib/SCMiddleware/libexpat.so \
      "$out/usr/lib/SCMiddleware/libexpat.so"
    install -Dm644 extracted/usr/lib/SCMiddleware/libfontconfig.so \
      "$out/usr/lib/SCMiddleware/libfontconfig.so"
    install -Dm644 extracted/usr/lib/SCMiddleware/libfreetype.so \
      "$out/usr/lib/SCMiddleware/libfreetype.so"
    install -Dm644 extracted/usr/lib/SCMiddleware/libpng16.so \
      "$out/usr/lib/SCMiddleware/libpng16.so"
    install -Dm644 extracted/usr/lib/SCMiddleware/libxmlsec1.so \
      "$out/usr/lib/SCMiddleware/libxmlsec1.so"
    install -Dm644 extracted/usr/lib/SCMiddleware/libxmlsec1-openssl.so \
      "$out/usr/lib/SCMiddleware/libxmlsec1-openssl.so"
    install -Dm644 extracted/usr/lib/SCMiddleware/libdigidoc.so \
      "$out/usr/lib/SCMiddleware/libdigidoc.so"
    install -Dm644 extracted/usr/share/SCMiddleware/appIcon.png \
      "$out/usr/share/SCMiddleware/appIcon.png"
    install -Dm644 extracted/usr/share/SCMiddleware/application.png \
      "$out/usr/share/SCMiddleware/application.png"
    install -Dm644 extracted/usr/share/SCMiddleware/branding.bin \
      "$out/usr/share/SCMiddleware/branding.bin"
    install -Dm644 extracted/usr/share/SCMiddleware/checkBanner.png \
      "$out/usr/share/SCMiddleware/checkBanner.png"
    install -Dm644 extracted/usr/share/SCMiddleware/checkIcon.png \
      "$out/usr/share/SCMiddleware/checkIcon.png"
    install -Dm644 extracted/usr/share/SCMiddleware/crossBanner.png \
      "$out/usr/share/SCMiddleware/crossBanner.png"
    install -Dm644 extracted/usr/share/SCMiddleware/crossIcon.png \
      "$out/usr/share/SCMiddleware/crossIcon.png"
    install -Dm644 extracted/usr/share/SCMiddleware/loadIcon.png \
      "$out/usr/share/SCMiddleware/loadIcon.png"
    install -Dm644 extracted/usr/share/SCMiddleware/tokmgr.bin \
      "$out/usr/share/SCMiddleware/tokmgr.bin"
    install -Dm644 extracted/usr/share/SCMiddleware/xsd.bin \
      "$out/usr/share/SCMiddleware/xsd.bin"
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
