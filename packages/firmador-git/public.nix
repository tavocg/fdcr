{ callPackage, metarepo, package }:
callPackage ../firmador/publish-snapshots.nix {
  inherit metarepo package;
  snapshots = callPackage ./snapshots.nix { };
}
