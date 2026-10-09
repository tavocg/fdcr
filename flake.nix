{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.metarepo.url = "github:alturalabscr/metarepo";
  inputs.metarepo.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { metarepo, ... }:
    {
      packages = metarepo.lib.mkPackages {
        packagesDir = ./packages;
        repository = import ./repository.nix;
      };
    };
}
