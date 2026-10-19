# Módulo NixOS para Firma Digital de Costa Rica.
{ self }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.fdcr;
  packages = self.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  options.services.fdcr = {
    enable = lib.mkEnableOption "Firma Digital de Costa Rica";
    certificates = {
      enable = lib.mkEnableOption "las CA raíz de Firma Digital en el almacén del sistema";
      package = lib.mkOption {
        type = lib.types.package;
        default = packages.bccr-certs;
        description = "Paquete de certificados y conjuntos PEM de Firma Digital.";
      };
    };

    gaudi = {
      enable = lib.mkEnableOption "el agente GAUDI y su inicio de sesión gráfico";
      package = lib.mkOption {
        type = lib.types.package;
        default = packages.bccr-gaudi;
        description = "Paquete del agente GAUDI.";
      };
    };

  };
  config = lib.mkIf cfg.enable {
    services.pcscd.enable = true;
    environment.systemPackages = [
      packages.opensc
    ]
    ++ lib.optional cfg.gaudi.enable cfg.gaudi.package
    ++ lib.optional cfg.certificates.enable cfg.certificates.package;
    security.pki.certificateFiles = lib.mkIf cfg.certificates.enable [
      "${cfg.certificates.package}/share/bccr-certs/pem/roots.pem"
    ];
  };
}
