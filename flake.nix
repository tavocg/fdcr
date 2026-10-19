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
              ];
          };
      };
      packages = nixpkgs.lib.mapAttrs (
        system: native:
        let
          firmador =
            base:
            base.override {
              pkcs11Module = "${native.opensc}/lib/opensc-pkcs11.so";
            };
        in
        native
        // {
          firmador = firmador native.firmador;
          firmador-git = firmador native.firmador-git;
          build-public = nixpkgs.legacyPackages.${system}.writeShellApplication {
            name = "build-public";
            runtimeInputs = [ nixpkgs.legacyPackages.${system}.python3 ];
            text = ''
              ${native.build-public}/bin/build-public
              python3 ${./lib/windows-index.py} public/win
            '';
          };
        }
        // nixpkgs.lib.optionalAttrs (system == "x86_64-linux") (
          nixpkgs.lib.genAttrs [ "firmador-msi" "firmador-git-msi" "opensc-msi" "opensc-git-msi" ] (
            name:
            (metarepo.lib.forPkgs nixpkgs.legacyPackages.${system}).mkMsiInstaller
              native.${nixpkgs.lib.removeSuffix "-msi" name}.windowsInstallerOptions
          )
        )
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
            "firmador"
          ];
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
          windows = import ./tests/windows.nix {
            inherit pkgs packages;
            metarepo = metarepo.lib.forPkgs pkgs;
          };
          nixos = import ./tests/nixos.nix {
            inherit pkgs nixpkgs;
            module = self.nixosModules.default;
          };
        }
      ) self.legacyPackages;
    };
}
