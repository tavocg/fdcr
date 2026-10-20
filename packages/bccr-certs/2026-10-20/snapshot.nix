{ system }:
let
  inherit (import ../../../lib/environments/2026-10-11.nix { inherit system; }) callPackage;
  builders = callPackage ../builders.nix { };
in
{
  builder = builders.artifacts_2026_10_11;
  source = (callPackage ./source.nix { }).src;
  version = "2026.10.20";
  dependencies = import ./dependencies.nix;
  publication.release = "1";
}
