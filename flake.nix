{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.metarepo.url = "github:alturalabscr/metarepo";
  inputs.metarepo.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    {
      self,
      nixpkgs,
      metarepo,
      ...
    }:
    {
      legacyPackages = metarepo.lib.mkPackages {
        packagesDir = ./packages;
        repository = import ./repository.nix;
        pkgsFor =
          system:
          import nixpkgs {
            inherit system;
            config.allowUnfreePredicate =
              package:
              builtins.elem (package.pname or package.name) [
                "bccr-certs"
                "bccr-gaudi"
                "idopte-p11"
                "idopte-scmanager"
              ];
          };
      };
      # Los payloads y publicaciones nativos permanecen en legacyPackages.
      packages = nixpkgs.lib.mapAttrs (
        system: native:
        if system != "x86_64-linux" then
          native
        else
          let
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
            env = import ./lib/nix/environments.nix {
              inherit pkgs;
              packages = native;
            };
            firmador =
              base:
              nixpkgs.lib.makeOverridable (
                {
                  pkcs11Module ? "${env.middleware}/lib/SCMiddleware/libidop11.so",
                }:
                env.firmadorEnv { inherit base pkcs11Module; }
              ) { };
          in
          native
          // {
            idopte-p11 = env.middleware;
            idopte-scmanager = env.scmanagerEnv {
              base = native.idopte-scmanager;
              nautilusSupport = false;
            };
            firmador = firmador native.firmador;
            firmador-git = firmador native.firmador-git;
          }
      ) self.legacyPackages;
      devShells.x86_64-linux =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          packages = self.packages.x86_64-linux;
          shell =
            names:
            pkgs.mkShell {
              packages = map (name: packages.${name}) names;
            };
        in
        {
          default = shell [
            "idopte-scmanager"
            "firmador"
          ];
          scmanager = shell [ "idopte-scmanager" ];
          firmador = shell [ "firmador" ];
          firmador-git = shell [ "firmador-git" ];
        };
      nixosModules = {
        fdcr = import ./modules/fdcr.nix { inherit self; };
        default = self.nixosModules.fdcr;
      };
      checks = nixpkgs.lib.mapAttrs (
        system: packages:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          snapshots = import ./tests/snapshots.nix {
            inherit pkgs packages;
            metarepo = metarepo.lib.forPkgs pkgs;
            repository = import ./repository.nix;
          };
          nixos = import ./tests/nixos.nix {
            inherit pkgs nixpkgs;
            module = self.nixosModules.default;
          };
        }
      ) self.legacyPackages;
    };
}
