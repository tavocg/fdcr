{
  lib,
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
    substituteInPlace "$out/usr/bin/firmador" \
      --replace-fail '@java@' '/usr/bin/java' \
      --replace-fail '@jar@' '/usr/share/firmador/firmador.jar'
    chmod 755 "$out/usr/bin/firmador"
  '';
  common = {
    inherit payload;
    name = package.pname;
    version = package.upstreamVersion;
    inherit (package) release;
    maintainer = "Firmador authors <firmador@libre.cr>";
    inherit (package.meta) description homepage;
    license = package.meta.license.spdxId;
  };
  builders = {
    deb = metarepo.mkApt;
    dnf = metarepo.mkDnf;
    pacman = metarepo.mkPacman;
  };
  dependencies = {
    deb = [ "openjdk-21-jre | java21-runtime" ];
    dnf = [ "java-21-openjdk" ];
    pacman = [ "java-runtime>=21" ];
  };
  packages = lib.mapAttrs (
    format: builder:
    builder (common // {
      architecture = package.passthru.packageArchitectures.${format};
      depends = dependencies.${format};
    })
  ) builders;
in
{
  channels = {
    jammy = packages.deb;
    noble = packages.deb;
    fedora = packages.dnf;
    arch = packages.pacman;
  };
}
