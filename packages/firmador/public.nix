{ callPackage, metarepo, repository, package }:
callPackage ./publish-snapshots.nix { inherit metarepo repository package; }
