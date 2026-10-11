{
  runCommand,
  unzip,
  rpm,
  cpio,
}:
let
  pinFile = import ../../../lib/recipes/2026-10-11/pin-file.nix;
  zip = pinFile ../../sfd_ClientesLinux_RPM64_rev26_08.zip;
  bundle = runCommand "fdcr-artifacts-rpm-2026-10-11" { nativeBuildInputs = [ unzip ]; } ''
    printf '%s  %s\n' '364b804cb3db5f078a0317df64e6dd2c5d75c6f126bf3d576f892fe5b5dd0664' '${zip}' | sha256sum --check --status
    mkdir -p "$out/certificates"
    unzip -p '${zip}' 'sfd_ClientesLinux_RPM64_26_08/Firma Digital/Idopte/scmiddleware-costa-rica-user_idopte_6.23.50.5_rh9_amd64.rpm' > "$out/idopte.rpm"
    unzip -p '${zip}' 'sfd_ClientesLinux_RPM64_26_08/Firma Digital/Agente GAUDI/agente-gaudi_29.0_amd64.rpm' > "$out/gaudi.rpm"
    unzip -j -q '${zip}' 'sfd_ClientesLinux_RPM64_26_08/Firma Digital/Certificados/*' -d "$out/certificates"
  '';
  extract =
    component:
    runCommand "fdcr-${component}-rpm-extracted"
      {
        nativeBuildInputs = [
          rpm
          cpio
        ];
      }
      ''
        mkdir -p "$out"
        cd "$out"
        rpm2cpio ${bundle}/${component}.rpm | cpio -idm --no-preserve-owner
        mkdir -p vendor-control
        rpm -qp --requires ${bundle}/${component}.rpm > vendor-control/requires
        rpm -qp --scripts ${bundle}/${component}.rpm > vendor-control/scripts
        chmod -R go-w "$out"
      '';
in
{
  inherit bundle;
  idopte = extract "idopte";
  gaudi = extract "gaudi";
  certificates = "${bundle}/certificates";
}
