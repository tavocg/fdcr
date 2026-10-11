{ callPackage, metarepo, repository, package }:
callPackage ../firmador/publish-snapshots.nix { inherit metarepo repository package; }
