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
    mkdir -p "$out"
    cp -R extracted/. "$out/"
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
