{ system }:
let
  inherit (import ../../../lib/environments/2026-10-11.nix { inherit system; }) callPackage;
  builders = callPackage ../builders.nix { };
in
{
  builder = builders.artifacts_2026_10_11;
  source = callPackage ./source.nix { };
  version = "2.12.7+dfsg+really2.9.14";
  dependencies = import ./dependencies.nix;
  publication.release = "2.1+deb13u3";
}
