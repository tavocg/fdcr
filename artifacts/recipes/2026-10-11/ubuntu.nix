# Vendor bundles shared by Idopte, GAUDI and the national certificates.
{
  lib,
  runCommand,
  unzip,
  dpkg,
}:
let
  fetchArtifact = import ../../../lib/recipes/2026-10-11/fetch-artifact.nix;
  # Commit that stores the vendor ZIPs; the LFS media endpoint serves the real
  # content for this revision even when the flake input only carries pointers.
  artifact = {
    owner = "tavocg";
    repo = "fdcr";
    rev = "82d7d2ffd55c14f49b0af6bfde9050f72b33c9a8";
  };
  nobleRoot = "sfd_ClientesLinux_DEB64_Ubuntu24_26_08/Firma Digital";
  jammyRoot = "sfd_ClientesLinux_DEB64_Ubuntu22_26_08/Firma Digital";
  sources = {
    noble = {
      zip = fetchArtifact (artifact // {
        path = "artifacts/sfd_ClientesLinux_DEB64_Ubuntu24_rev26_08.zip";
        sha256 = "0e84d21120c2c9be7f419921ee85d1ef75e7d6e119af2e9168acdb3df1b84c52";
      });
      idopte = "${nobleRoot}/Idopte/Idopte_6.23.50.5_ubun24_amd64.deb";
      gaudi = "${nobleRoot}/Agente GAUDI/agente-gaudi_29.0_amd64.deb";
      certificates = "${nobleRoot}/Certificados";
    };
    jammy = {
      zip = fetchArtifact (artifact // {
        path = "artifacts/sfd_ClientesLinux_DEB64_Ubuntu22_rev26_08.zip";
        sha256 = "e5b5e5827f1a20ff76a22e32396dc53b30190761912f0e1f06e3632be11416b5";
      });
      idopte = "${jammyRoot}/Idopte/Idopte_6.23.50.5_ubun22_amd64.deb";
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
        unzip -p '${source.zip}' '${source.idopte}' > "$out/idopte.deb"
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
      idopte = extractDeb release bundle "idopte";
      gaudi = extractDeb release bundle "gaudi";
      certificates = "${bundle}/certificates";
    }
  ) sources;
}
