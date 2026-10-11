let
  versions = {
    gaudi = "29.0";
    idopte = "6.23.50.5";
    certificates = "2026.08";
  };
  release = "1";
  variant = ubuntu: md5: channels:
    let root = "sfd_ClientesLinux_DEB64_Ubuntu${ubuntu}_26_08/Firma Digital";
    in {
      zip = ../../. + "/sfd_ClientesLinux_DEB64_Ubuntu${ubuntu}_rev26_08.zip";
      inherit md5 channels;
      idopte = "${root}/Idopte/Idopte_${versions.idopte}_ubun${ubuntu}_amd64.deb";
      gaudi = "${root}/Agente GAUDI/agente-gaudi_${versions.gaudi}_amd64.deb";
      certificates = "${root}/Certificados";
    };
in {
  inherit versions release;
  dependencies = {
    gaudi = import ./gaudi.nix;
    idopte-p11 = import ./idopte-p11.nix;
    idopte-scmanager = import ./idopte-scmanager.nix {
      version = versions.idopte;
      inherit release;
    };
  };
  variants = {
    noble = variant "24" "7e5c2772f958a9fd855d41d7d5c26a52" [ "noble" "fedora" "arch" ];
    jammy = variant "22" "348e3c06ef5218542266bdf417c13e36" [ "jammy" ];
  };
}
