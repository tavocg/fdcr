{
  lib,
  maven,
  makeWrapper,
  pname ? "firmador",
  version,
  src,
  mvnHash,
  buildJdk,
  compilerParameters,
  dependencies,
  # Rutas de compilación nativas fijan el middleware en el payload. En Nix se
  # pasa la biblioteca PKCS#11 del middleware para exportar LIBASEP11 en el
  # lanzador; `null` conserva exactamente la derivación publicada.
  pkcs11Module ? null,
  # Firmador 1.9.8 no lee LIBASEP11, así que las recetas de Nix parchean la
  # fuente; `[ ]` conserva exactamente la derivación publicada.
  patches ? [ ],
}:
let
  pinFile = import ../../../../lib/recipes/2026-10-11/pin-file.nix;
  # `override` en la derivación solo cambia este bloque; con `null` el texto es
  # idéntico al de las recetas históricas.
  wrapper = lib.optionalString (pkcs11Module != null) ''
    wrapProgram "$out/bin/${pname}" \
      --set-default LIBASEP11 ${lib.escapeShellArg (toString pkcs11Module)}
  '';
in
maven.buildMavenPackage {
  inherit pname version;

  inherit src;

  inherit patches;

  mvnJdk = buildJdk;
  inherit mvnHash;
  nativeBuildInputs = lib.optional (pkcs11Module != null) makeWrapper;
  # Each snapshot declares its Java compilation target explicitly.
  mvnParameters = "-Dmaven.test.skip=true ${compilerParameters}";
  doCheck = false;

  installPhase = ''
    runHook preInstall
    install -Dm644 target/firmador.jar "$out/share/${pname}/firmador.jar"
    install -Dm644 COPYING "$out/share/licenses/${pname}/COPYING"
    install -Dm755 ${pinFile ./launcher.sh} "$out/bin/${pname}"
    if [ -f flatpak/cr.libre.firmador.desktop ]; then
      install -Dm644 flatpak/cr.libre.firmador.desktop \
        "$out/share/applications/cr.libre.${pname}.desktop"
    else
      install -Dm644 ${pinFile ./firmador.desktop} \
        "$out/share/applications/cr.libre.${pname}.desktop"
    fi
    install -Dm644 src/main/resources/firmador.png \
      "$out/share/icons/hicolor/1024x1024/apps/cr.libre.${pname}.png"
    sed -i '/^StartupWMClass=/d; /^Exec=/d; /^Icon=/d; /^Name=/d' \
      "$out/share/applications/cr.libre.${pname}.desktop"
    cat >> "$out/share/applications/cr.libre.${pname}.desktop" <<'EOF'
    Name=Firmador Libre${lib.optionalString (pname == "firmador-git") " (Git)"}
    Exec=${pname} %U
    Icon=cr.libre.${pname}
    StartupWMClass=Firmador
    EOF
    substituteInPlace "$out/bin/${pname}" \
      --replace-fail '@java@' '${buildJdk}/bin/java' \
      --replace-fail '@jar@' "$out/share/${pname}/firmador.jar"
    ${wrapper}runHook postInstall
  '';

  passthru = {
    inherit dependencies;
    packageArchitectures = {
      apt = "all";
      dnf = "noarch";
      pacman = "any";
    };
  };

  meta = {
    description = "Firma digital de documentos en Costa Rica";
    homepage = "https://firmador.libre.cr/";
    license = lib.licenses.gpl3Plus;
    maintainers = [
      {
        name = "Firmador authors";
        email = "firmador@libre.cr";
      }
    ];
    mainProgram = pname;
    platforms = import ../../systems.nix;
  };
}
