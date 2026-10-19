# Immutable toolchain for recipes registered on 2026-10-11.
# Updating flake.lock affects discovery; historical builders keep these inputs.
{ system }:
let
  nixpkgsSource = builtins.fetchTree {
    type = "github";
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "e7439b6b14ad3cc35d05608ebca9bce01a25f5f8";
    narHash = "sha256-H83yz/do+hjOO0uujHyH8RgtIQP2v7Mw+cLwcZK/xKc=";
  };
  metarepoSource = builtins.fetchTree {
    type = "github";
    owner = "alturalabscr";
    repo = "metarepo";
    rev = "ac1e55fd39dfce83eea6e97546fb7f8d0fe74ab4";
    narHash = "sha256-LVdl8hlzkS1XZPMnq0HXlVJMk/PlVH1fTTfimkLqErk=";
  };
  pkgs = import nixpkgsSource.outPath {
    inherit system;
    config.allowUnfreePredicate =
      package:
      builtins.elem (package.pname or package.name) [
        "bccr-certs"
        "bccr-gaudi"
      ];
  };
  metarepo =
    (import (metarepoSource.outPath + "/lib") {
      nixpkgs = { inherit (pkgs) lib; };
    }).forPkgs
      pkgs;
  callPackage = pkgs.lib.callPackageWith (pkgs // { inherit metarepo callPackage; });
in
{
  inherit pkgs metarepo callPackage;
}
