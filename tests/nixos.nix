# Evalúa el módulo NixOS contra un sistema mínimo. No construye el cierre:
# solo fuerza las derivaciones del middleware y la configuración del servicio.
{
  pkgs,
  nixpkgs,
  module,
}:
let
  inherit (pkgs) lib;
  system = pkgs.stdenv.hostPlatform.system;
in
if system != "x86_64-linux" then
  pkgs.runCommand "fdcr-nixos-module-unsupported" { } "touch $out"
else
  let
    evaluated = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        module
        {
          services.fdcr.enable = true;
          services.fdcr.middleware.enable = true;
          services.fdcr.certificates.enable = true;
          services.fdcr.scmanager.enable = true;
          services.fdcr.scmanager.nautilus.enable = true;
          services.fdcr.gaudi.enable = true;

          nixpkgs.config.allowUnfreePredicate =
            package:
            builtins.elem (package.pname or package.name) [
              "bccr-certs"
              "bccr-gaudi"
              "idopte-p11"
              "idopte-scmanager"
            ];

          boot.loader.grub.enable = false;
          fileSystems."/" = {
            device = "/dev/null";
            fsType = "ext4";
          };
          networking.hostName = "fdcr-test";
          system.stateVersion = "24.05";
        }
      ];
    };
    fdcr = evaluated.config.services.fdcr;
  in
  assert lib.all (package: builtins.isString package.drvPath) evaluated.config.environment.systemPackages;
  assert builtins.isString fdcr.package.drvPath;
  assert lib.hasPrefix "/nix/store/" (toString fdcr.pkcs11Module);
  assert lib.hasSuffix "/lib/SCMiddleware/libidop11.so" (toString fdcr.pkcs11Module);
  pkgs.runCommand "fdcr-nixos-module-regressions" { } "touch $out"
