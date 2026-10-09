{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.metarepo.url = "github:alturalabscr/metarepo";
  inputs.metarepo.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { nixpkgs, metarepo, ... }:
    {
      packages = metarepo.lib.mkPackages {
        packagesDir = ./packages;
        repository = import ./repository.nix;
        pkgsFor = system: import nixpkgs {
          inherit system;
          config.allowUnfreePredicate = package: package.pname or package.name == "idopte-p11";
        };
      };
    };
}
