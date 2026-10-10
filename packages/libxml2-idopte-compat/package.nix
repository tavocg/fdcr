{ lib, stdenv, callPackage, dpkg }:
stdenv.mkDerivation {
  pname = "libxml2-idopte-compat";
  version = "2.12.7+dfsg+really2.9.14";

  src = (callPackage ../../artifacts/artifacts.nix { }).libxml2Compat;
  nativeBuildInputs = [ dpkg ];
  unpackPhase = ''
    runHook preUnpack
    dpkg-deb --extract "$src" extracted
    runHook postUnpack
  '';
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    # Idopte's RUNPATH already searches here. Keep the system libxml2 untouched.
    install -d "$out/usr/lib/SCMiddleware"
    cp -a extracted/usr/lib/x86_64-linux-gnu/libxml2.so.2* \
      "$out/usr/lib/SCMiddleware/"
    install -d "$out/usr/share/doc/libxml2-idopte-compat"
    cp -a extracted/usr/share/doc/libxml2/. \
      "$out/usr/share/doc/libxml2-idopte-compat/"
    runHook postInstall
  '';

  meta = {
    description = "Private libxml2 ABI 2 compatibility library for Idopte";
    homepage = "https://gitlab.gnome.org/GNOME/libxml2";
    license = lib.licenses.mit;
    platforms = import ./systems.nix;
  };
}
