{ lib, callPackage, runCommand, unzip, dpkg, revision, record }:
let
  publications = (callPackage ./idopte-publication.nix { }) // {
    gaudi = callPackage ./gaudi-publication.nix { };
    certificates = callPackage ./certificates-publication.nix { };
  };
  extractBundle = variant: source: runCommand "fdcr-artifacts-${revision}-${variant}" {
    nativeBuildInputs = [ unzip ];
  } ''
    printf '%s  %s\n' '${source.md5}' '${source.zip}' | md5sum --check --status || {
      echo "Source ZIP MD5 mismatch" >&2
      exit 1
    }
    mkdir -p "$out/certificates"
    unzip -p '${source.zip}' '${source.idopte}' > "$out/idopte.deb"
    unzip -p '${source.zip}' '${source.gaudi}' > "$out/gaudi.deb"
    unzip -j -q '${source.zip}' '${source.certificates}/*' -d "$out/certificates"
  '';
  extractDeb = variant: bundle: component:
    runCommand "fdcr-${component}-${revision}-${variant}-extracted" {
      nativeBuildInputs = [ dpkg ];
    } ''
      dpkg-deb --extract ${bundle}/${component}.deb "$out"
      chmod -R go-w "$out"
    '';
in
lib.mapAttrs (variant: source:
  let
    bundle = extractBundle variant source;
    idopte = extractDeb variant bundle "idopte";
    component = name: src: version: {
      inherit src version;
      publication = {
        inherit (record) release;
        inherit (source) channels;
      } // publications.${name} // lib.optionalAttrs (record.dependencies ? ${name}) {
        formats = {
          apt.depends = record.dependencies.${name}.${variant};
          dnf.depends = record.dependencies.${name}.dnf;
          pacman.depends = record.dependencies.${name}.pacman;
        };
      };
    };
  in {
    idopte-p11 = component "idopte-p11" idopte record.versions.idopte;
    idopte-scmanager = component "idopte-scmanager" idopte record.versions.idopte;
    bccr-gaudi = component "gaudi" (extractDeb variant bundle "gaudi") record.versions.gaudi;
    bccr-certs = component "certificates" "${bundle}/certificates" record.versions.certificates;
  }
) record.variants
