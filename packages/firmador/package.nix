{
  lib,
  fetchFromCodeberg,
  maven,
  jdk21,
  buildJdk ? jdk21,
  pname ? "firmador",
  version ? "1.9.8",
  rev ? "09953947a51d87c2a146189ec76b6c27ab6518a1",
  hash ? "sha256-xdiVPjihRADPK4nG+WQHWsDzVYLCeN6ouQ6SDtjf1qQ=",
  mvnHash ? "sha256-opTjZA50tInbAmfGT1rJI3cC0+dUdYrIh8ZWReVeKWA=",
  compilerParameters ? "-Dmaven.compiler.source=8 -Dmaven.compiler.target=8",
}:
maven.buildMavenPackage {
  inherit pname version;

  src = fetchFromCodeberg {
    owner = "firmador";
    repo = "firmador";
    inherit rev hash;
  };

  mvnJdk = buildJdk;
  inherit mvnHash;
  # The stable base classes must remain runnable on Java 8.
  mvnParameters = "-Dmaven.test.skip=true ${compilerParameters}";
  doCheck = false;

  installPhase = ''
    runHook preInstall
    install -Dm644 target/firmador.jar "$out/share/${pname}/firmador.jar"
    install -Dm644 COPYING "$out/share/licenses/${pname}/COPYING"
    install -Dm755 ${./launcher.sh} "$out/bin/${pname}"
    if [ -f flatpak/cr.libre.firmador.desktop ]; then
      install -Dm644 flatpak/cr.libre.firmador.desktop \
        "$out/share/applications/cr.libre.${pname}.desktop"
    else
      install -Dm644 ${./firmador.desktop} \
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
    runHook postInstall
  '';

  passthru = {
    release = "1";
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
    maintainers = [ {
      name = "Firmador authors";
      email = "firmador@libre.cr";
    } ];
    mainProgram = pname;
    platforms = import ./systems.nix;
  };
}
