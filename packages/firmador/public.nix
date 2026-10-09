{
  metarepo,
  runCommand,
  package,
}:
let
  payload = runCommand "firmador-payload" { } ''
    mkdir -p "$out/usr/bin" "$out/usr/share/firmador" "$out/usr/share/licenses/firmador"
    cp ${package}/share/firmador/firmador.jar "$out/usr/share/firmador/firmador.jar"
    cp ${package}/share/licenses/firmador/COPYING "$out/usr/share/licenses/firmador/COPYING"
    cp ${./launcher.sh} "$out/usr/bin/firmador"
    install -Dm644 ${package}/share/applications/cr.libre.firmador.desktop \
      "$out/usr/share/applications/cr.libre.firmador.desktop"
    install -Dm644 ${package}/share/icons/hicolor/scalable/apps/cr.libre.firmador.svg \
      "$out/usr/share/icons/hicolor/scalable/apps/cr.libre.firmador.svg"
    ln -s firmador "$out/usr/bin/cr.libre.firmador.sh"
    substituteInPlace "$out/usr/bin/firmador" \
      --replace-fail '@java@' '/usr/bin/java' \
      --replace-fail '@jar@' '/usr/share/firmador/firmador.jar'
    chmod 755 "$out/usr/bin/firmador"
  '';
  common = {
    inherit payload;
    name = package.pname;
    version = package.version;
    inherit (package) release;
    maintainer = "Firmador authors <firmador@libre.cr>";
    inherit (package.meta) description homepage;
    license = package.meta.license.spdxId;
    recommends = [ "idopte-p11" ];
  };
  architectures = package.passthru.packageArchitectures;
  apt = metarepo.mkApt (common // {
    architecture = architectures.apt;
    depends = [ "openjdk-21-jre | java21-runtime" ];
  });
  dnf = metarepo.mkDnf (common // {
    architecture = architectures.dnf;
    depends = [ "java" ];
  });
  pacman = metarepo.mkPacman (common // {
    architecture = architectures.pacman;
    depends = [ "java-runtime>=21" ];
  });
in
{
  channels = {
    jammy = apt;
    noble = apt;
    fedora = dnf;
    arch = pacman;
  };
}
