# GAUDI and national certificates.
{
  lib,
  runCommand,
  unzip,
  dpkg,
}:
let
  # Restore pinFile and the ZIP references when the artifacts are added again.
  # pinFile = import ../../../lib/recipes/2026-10-11/pin-file.nix;
  nobleRoot = "sfd_ClientesLinux_DEB64_Ubuntu24_26_08/Firma Digital";
  jammyRoot = "sfd_ClientesLinux_DEB64_Ubuntu22_26_08/Firma Digital";
  sources = {
    noble = {
      # zip = pinFile ../../bccr-noble-2026.08.zip;
      zip = throw "BCCR artifacts (noble) temporarily removed; restore them to build bccr-certs and bccr-gaudi.";
      gaudi = "${nobleRoot}/Agente GAUDI/agente-gaudi_29.0_amd64.deb";
      certificates = "${nobleRoot}/Certificados";
    };
    jammy = {
      # zip = pinFile ../../bccr-jammy-2026.08.zip;
      zip = throw "BCCR artifacts (jammy) temporarily removed; restore them to build bccr-certs and bccr-gaudi.";
      gaudi = "${jammyRoot}/Agente GAUDI/agente-gaudi_29.0_amd64.deb";
      certificates = "${jammyRoot}/Certificados";
    };
  };

  extractBundle =
    release: source:
    runCommand "fdcr-artifacts-${release}"
      {
        nativeBuildInputs = [ unzip ];
      }
      ''
        mkdir -p "$out/certificates"
        unzip -p '${source.zip}' '${source.gaudi}' > "$out/gaudi.deb"
        unzip -j -q '${source.zip}' '${source.certificates}/*' -d "$out/certificates"
      '';

  extractDeb =
    release: bundle: component:
    runCommand "fdcr-${component}-${release}-extracted"
      {
        nativeBuildInputs = [ dpkg ];
      }
      ''
        dpkg-deb --extract ${bundle}/${component}.deb "$out"
        # Extract control metadata for auditing; never execute vendor scripts here.
        dpkg-deb --control ${bundle}/${component}.deb "$out/vendor-control"
        # Vendor archives may contain writable-by-others paths, rejected by Nix.
        chmod -R go-w "$out"
      '';
in
{
  variants = lib.mapAttrs (
    release: source:
    let
      bundle = extractBundle release source;
    in
    {
      inherit bundle;
      gaudi = extractDeb release bundle "gaudi";
      certificates = "${bundle}/certificates";
    }
  ) sources;
}
