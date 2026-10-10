{ callPackage, metarepo, package }:
callPackage ./publish-snapshots.nix {
  inherit metarepo package;
  snapshots = callPackage ./snapshots.nix { };
}
