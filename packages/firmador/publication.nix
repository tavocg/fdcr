{ lib, metarepo, repository, runCommand, package }:
let
  name = package.pname;
  payload = runCommand "${name}-payload" { } ''
    cp -R ${metarepo.mkPayload { inherit package; }} "$out"
    chmod -R u+w "$out"
    cp ${./launcher.sh} "$out/usr/bin/${name}"
    substituteInPlace "$out/usr/bin/${name}" \
      --replace-fail '@java@' '/usr/bin/java' \
      --replace-fail '@jar@' '/usr/share/${name}/firmador.jar'
    chmod 755 "$out/usr/bin/${name}"
    ln -s ${name} "$out/usr/bin/cr.libre.${name}.sh"
    # Some themes do not search the 1024x1024 directory.
    substituteInPlace "$out/usr/share/applications/cr.libre.${name}.desktop" \
      --replace-fail 'Icon=cr.libre.${name}' \
        'Icon=/usr/share/icons/hicolor/1024x1024/apps/cr.libre.${name}.png'
  '';
in
metarepo.mkPublication {
  inherit repository package payload;
  independent = true;
  maintainer = "Firmador authors <firmador@libre.cr>";
  formats = lib.mapAttrs (_: depends: { inherit depends; }) package.javaDependencies;
}
