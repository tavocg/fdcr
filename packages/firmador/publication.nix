{
  metarepo,
  runCommand,
  package,
}:
let
  name = package.pname;
  javaDependencies = package.javaDependencies;
  payload = runCommand "${name}-payload" { } ''
    mkdir -p "$out/usr/bin" "$out/usr/share/${name}" "$out/usr/share/licenses/${name}"
    cp ${package}/share/${name}/firmador.jar "$out/usr/share/${name}/firmador.jar"
    cp ${package}/share/licenses/${name}/COPYING "$out/usr/share/licenses/${name}/COPYING"
    cp ${./launcher.sh} "$out/usr/bin/${name}"
    install -Dm644 ${package}/share/applications/cr.libre.${name}.desktop \
      "$out/usr/share/applications/cr.libre.${name}.desktop"
    install -Dm644 ${package}/share/icons/hicolor/1024x1024/apps/cr.libre.${name}.png \
      "$out/usr/share/icons/hicolor/1024x1024/apps/cr.libre.${name}.png"
    ln -s ${name} "$out/usr/bin/cr.libre.${name}.sh"
    substituteInPlace "$out/usr/bin/${name}" \
      --replace-fail '@java@' '/usr/bin/java' \
      --replace-fail '@jar@' '/usr/share/${name}/firmador.jar'
    chmod 755 "$out/usr/bin/${name}"
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
    depends = javaDependencies.apt;
  });
  dnf = metarepo.mkDnf (common // {
    architecture = architectures.dnf;
    depends = javaDependencies.dnf;
  });
  pacman = metarepo.mkPacman (common // {
    architecture = architectures.pacman;
    depends = javaDependencies.pacman;
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
