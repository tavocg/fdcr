# Vendor bundles shared by Idopte, GAUDI and the national certificates.
{ lib, runCommand, unzip, dpkg }:
let
  nobleRoot = "sfd_ClientesLinux_DEB64_Ubuntu24_26_08/Firma Digital";
  jammyRoot = "sfd_ClientesLinux_DEB64_Ubuntu22_26_08/Firma Digital";
  sources = {
    noble = {
      zip = ./sfd_ClientesLinux_DEB64_Ubuntu24_rev26_08.zip;
      md5 = "7e5c2772f958a9fd855d41d7d5c26a52";
      idopte = "${nobleRoot}/Idopte/Idopte_6.23.50.5_ubun24_amd64.deb";
      gaudi = "${nobleRoot}/Agente GAUDI/agente-gaudi_29.0_amd64.deb";
      certificates = "${nobleRoot}/Certificados";
    };
    jammy = {
      zip = ./sfd_ClientesLinux_DEB64_Ubuntu22_rev26_08.zip;
      md5 = "348e3c06ef5218542266bdf417c13e36";
      idopte = "${jammyRoot}/Idopte/Idopte_6.23.50.5_ubun22_amd64.deb";
      gaudi = "${jammyRoot}/Agente GAUDI/agente-gaudi_29.0_amd64.deb";
      certificates = "${jammyRoot}/Certificados";
    };
  };

  extractBundle = release: source: runCommand "fdcr-artifacts-${release}" {
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

  extractDeb = release: bundle: component:
    runCommand "fdcr-${component}-${release}-extracted" {
      nativeBuildInputs = [ dpkg ];
    } ''
      dpkg-deb --extract ${bundle}/${component}.deb "$out"
      # Vendor archives may contain writable-by-others paths, rejected by Nix.
      chmod -R go-w "$out"
    '';
in
lib.mapAttrs (release: source:
  let
    bundle = extractBundle release source;
  in {
    inherit bundle;
    idopte = extractDeb release bundle "idopte";
    gaudi = extractDeb release bundle "gaudi";
    certificates = "${bundle}/certificates";
  }
) sources
