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
      packages = metarepo.lib.mkPackages {
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
      ) self.packages;
    };
}
