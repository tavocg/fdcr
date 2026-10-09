{ lib, stdenv, dpkg, unzip }:
stdenv.mkDerivation {
  pname = "idopte-p11";
  version = "6.23.50.5";

  src = ./artifacts/sfd_ClientesLinux_DEB64_Ubuntu24_rev26_08.zip;

  nativeBuildInputs = [ dpkg unzip ];
  dontUnpack = true;

  buildPhase = ''
    runHook preBuild
    printf '%s  %s\n' '7e5c2772f958a9fd855d41d7d5c26a52' "$src" \
      | md5sum --check --status || {
        echo "Source ZIP MD5 mismatch" >&2
        exit 1
      }

    mkdir -p source
    unzip -p "$src" \
      'sfd_ClientesLinux_DEB64_Ubuntu24_26_08/Firma Digital/Idopte/Idopte_6.23.50.5_ubun24_amd64.deb' \
      > source/idopte.deb
    dpkg-deb --extract source/idopte.deb extracted
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
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
    install -Dm644 extracted/etc/idoss.conf "$out/etc/idoss.conf"
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
