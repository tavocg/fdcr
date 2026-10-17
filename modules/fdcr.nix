/**
  Módulo NixOS para Firma Digital de Costa Rica.

  El catálogo de paquetes publica árboles nativos (APT/DNF/Pacman) que esperan
  las rutas estándar de la distribución. Este módulo adapta esos payloads a
  NixOS: reubica el árbol del middleware en `$out/{etc,lib,share}` y enlaza las
  dependencias con `autoPatchelf`; SCManager se envuelve en `buildFHSEnv`. Las
  derivaciones publicadas no se modifican.
*/
{ self }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.fdcr;
  system = pkgs.stdenv.hostPlatform.system;
  packages = self.packages.${system};

  # NixOS no expone programs.nautilus.enable. GNOME instala Nautilus salvo que
  # se excluya explícitamente; otros escritorios pueden activarlo a mano.
  gnomeHasNautilus =
    (config.services.desktopManager.gnome.enable or false)
    && (config.services.gnome.core-apps.enable or false)
    && !(lib.any (package: lib.getName package == "nautilus") config.environment.gnome.excludePackages);

  environments = import ../lib/nix/environments.nix {
    inherit pkgs;
    packages = self.legacyPackages.${system};
    middlewarePackage = cfg.package;
  };
  middleware =
    (import ../lib/nix/environments.nix {
      inherit pkgs;
      packages = self.legacyPackages.${system};
    }).middleware;
  inherit (environments) scmanagerEnv;

in
{
  options.services.fdcr = {
    enable = lib.mkEnableOption "Firma Digital de Costa Rica";

    middleware.enable = lib.mkEnableOption "el middleware Idopte";

    package = lib.mkOption {
      type = lib.types.package;
      default = middleware;
      defaultText = lib.literalExpression "services.fdcr.middleware";
      description = ''
        Paquete del middleware Idopte adaptado a NixOS. Sus archivos quedan en
        `$out/lib/SCMiddleware` y `$out/etc`.
      '';
    };

    pkcs11Module = lib.mkOption {
      type = lib.types.path;
      default = "${cfg.package}/lib/SCMiddleware/libidop11.so";
      defaultText = lib.literalExpression ''"''${config.services.fdcr.package}/lib/SCMiddleware/libidop11.so"'';
      description = ''
        Biblioteca PKCS#11 que debe cargar Firmador. Úsala así:

        ```nix
        fdcr.firmador.override {
          pkcs11Module = config.services.fdcr.pkcs11Module;
        }
        ```
      '';
    };

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

    scmanager = {
      enable = lib.mkEnableOption "SCManager y su integración de escritorio";
      package = lib.mkOption {
        type = lib.types.package;
        default = self.legacyPackages.${system}.idopte-scmanager;
        description = ''
          Payload nativo de SCManager. El módulo lo envuelve en un entorno FHS
          según `scmanager.nautilus.enable`.
        '';
      };
      nautilus.enable = lib.mkOption {
        type = lib.types.bool;
        default = gnomeHasNautilus;
        description = ''
          Habilita la extensión de SCManager para Nautilus. Se activa por
          defecto con GNOME si Nautilus no está excluido. En otros escritorios,
          habilitar únicamente cuando Nautilus esté instalado.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.isx86_64;
        message = "FDCR: Firma Digital de Costa Rica solo está disponible para x86_64-linux.";
      }
    ];

    services.pcscd.enable = true;

    services.fdcr.middleware.enable = lib.mkDefault cfg.scmanager.enable;

    security.pki.certificateFiles = lib.mkIf cfg.certificates.enable [
      "${cfg.certificates.package}/share/bccr-certs/pem/roots.pem"
    ];

    environment.systemPackages =
      lib.optional cfg.gaudi.enable cfg.gaudi.package
      ++ lib.optional cfg.certificates.enable cfg.certificates.package
      ++ lib.optionals cfg.scmanager.enable [
        (scmanagerEnv {
          base = cfg.scmanager.package;
          nautilusSupport = cfg.scmanager.nautilus.enable;
        })
      ]
      ++ lib.optional cfg.scmanager.enable pkgs.nautilus-python;

    environment.pathsToLink = lib.mkIf (cfg.scmanager.enable && cfg.scmanager.nautilus.enable) [
      "/share/nautilus-python/extensions"
    ];
    environment.sessionVariables = lib.mkIf (cfg.scmanager.enable && cfg.scmanager.nautilus.enable) {
      NAUTILUS_4_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-4";
    };

    environment.etc = lib.mkIf cfg.middleware.enable {
      "idoss.conf".source = "${cfg.package}/etc/idoss.conf";
      "idoss.lic".source = "${cfg.package}/etc/idoss.lic";
    };

    systemd.tmpfiles.rules = lib.mkIf cfg.middleware.enable [
      "d /usr/lib/SCMiddleware 0755 root root -"
      "L+ /usr/lib/SCMiddleware/libt_ias.so - - - - ${cfg.package}/lib/SCMiddleware/libt_ias.so"
      "L+ /usr/lib/SCMiddleware/idocachesrv - - - - ${cfg.package}/lib/SCMiddleware/idocachesrv"
    ];
  };
}
