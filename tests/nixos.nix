# Evalúa el módulo NixOS y comprueba los paquetes y la activación de PC/SC.
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
          # Restore these integration checks with the BCCR artifacts.
          # services.fdcr.certificates.enable = true;
          # services.fdcr.gaudi.enable = true;

          nixpkgs.config.allowUnfreePredicate =
            package:
            builtins.elem (package.pname or package.name) [
              "bccr-certs"
              "bccr-gaudi"
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

  in
  assert lib.all (
    package: builtins.isString package.drvPath
  ) evaluated.config.environment.systemPackages;
  assert evaluated.config.services.pcscd.enable;
  pkgs.runCommand "fdcr-nixos-module-regressions" { } "touch $out"
