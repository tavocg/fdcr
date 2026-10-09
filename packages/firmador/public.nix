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
  deb = metarepo.mkApt (
    common
    // {
      architecture = package.passthru.packageArchitectures.deb;
      depends = [ "openjdk-21-jre | java21-runtime" ];
    }
  );
  dnf = metarepo.mkDnf (
    common
    // {
      architecture = package.passthru.packageArchitectures.dnf;
      depends = [ "java-21-openjdk" ];
    }
  );
  arch = metarepo.mkPacman (
    common
    // {
      architecture = package.passthru.packageArchitectures.pacman;
      depends = [ "java-runtime>=21" ];
    }
  );
in
{
  channels = {
    jammy = {
      releases = [ "ubuntu2204" ];
      package = deb;
    };
    noble = {
      releases = [ "ubuntu2404" "debian13" ];
      package = deb;
    };
    fedora = {
      releases = [ "fedora44" ];
      package = dnf;
    };
    arch = {
      releases = [ "arch" ];
      package = arch;
    };
  };
}
