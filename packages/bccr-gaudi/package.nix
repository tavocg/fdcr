{ callPackage, snapshots ? callPackage ./snapshots.nix { }, default ? "26_08-noble" }:
callPackage ../../lib/snapshots.nix { } {
  inherit snapshots default;
}
