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
        }
      ) self.packages;
    };
}
