{ package, runCommand }:
let
  pinFile = import ../../../../lib/recipes/2026-10-11/pin-file.nix;
  name = package.pname;
  payload = runCommand "${name}-payload" { } ''
    mkdir -p "$out/usr/bin" "$out/usr/share/${name}" "$out/usr/share/licenses/${name}"
    cp ${package}/share/${name}/firmador.jar "$out/usr/share/${name}/firmador.jar"
    cp ${package}/share/licenses/${name}/COPYING "$out/usr/share/licenses/${name}/COPYING"
    cp ${pinFile ./launcher.sh} "$out/usr/bin/${name}"
    install -Dm644 ${package}/share/applications/cr.libre.${name}.desktop \
      "$out/usr/share/applications/cr.libre.${name}.desktop"
    install -Dm644 ${package}/share/icons/hicolor/1024x1024/apps/cr.libre.${name}.png \
      "$out/usr/share/icons/hicolor/1024x1024/apps/cr.libre.${name}.png"
    # Some icon themes do not search the 1024x1024 directory.
    substituteInPlace "$out/usr/share/applications/cr.libre.${name}.desktop" \
      --replace-fail 'Icon=cr.libre.${name}' \
        'Icon=/usr/share/icons/hicolor/1024x1024/apps/cr.libre.${name}.png'
    ln -s ${name} "$out/usr/bin/cr.libre.${name}.sh"
    substituteInPlace "$out/usr/bin/${name}" \
      --replace-fail '@java@' '/usr/bin/java' \
      --replace-fail '@jar@' '/usr/share/${name}/firmador.jar'
    chmod 755 "$out/usr/bin/${name}"
  '';
in
{
  options = {
    inherit payload;
    independent = true;
    maintainer = "Firmador authors <firmador@libre.cr>";
    formats = {
      apt.depends = package.dependencies.apt;
      dnf.depends = package.dependencies.dnf;
      pacman.depends = package.dependencies.pacman;
    };
  };
}
