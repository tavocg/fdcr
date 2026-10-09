{
  lib,
  fetchFromCodeberg,
  maven,
  jdk21,
}:
maven.buildMavenPackage {
  pname = "firmador";
  version = "2.0.0-1";

  src = fetchFromCodeberg {
    owner = "firmador";
    repo = "firmador";
    rev = "a34e5b87b62093b22de95a543cf7edd303ec2676";
    hash = "sha256-ykDHGr1jdAkClgCVPVEIQWyo9idxjFfOem9TD1S6t9I=";
  };

  mvnJdk = jdk21;
  mvnHash = "sha256-X6hxe5v+w+0RtKYeAOjRy2HFetH8LeCBNauZQq+I928=";
  mvnParameters = "-Dmaven.test.skip=true";
  doCheck = false;

  installPhase = ''
    runHook preInstall
    install -Dm644 target/firmador.jar "$out/share/firmador/firmador.jar"
    install -Dm644 COPYING "$out/share/licenses/firmador/COPYING"
    install -Dm755 ${./launcher.sh} "$out/bin/firmador"
    substituteInPlace "$out/bin/firmador" \
      --replace-fail '@java@' '${jdk21}/bin/java' \
      --replace-fail '@jar@' "$out/share/firmador/firmador.jar"
    runHook postInstall
  '';

  passthru = {
    upstreamVersion = "2.0.0";
    release = "1";
    packageArchitectures = {
      deb = "all";
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
    mainProgram = "firmador";
    platforms = import ./systems.nix;
  };
}
