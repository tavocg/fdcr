{ system }:
let
  original = import ../2026-10-11/snapshot.nix { inherit system; };
  inherit (import ../../../lib/environments/2026-10-11.nix { inherit system; }) callPackage;
  builders = callPackage ../builders.nix { };
in
original
// {
  builder = builders.java_2026_10_20;
  publication.release = "2";
}
