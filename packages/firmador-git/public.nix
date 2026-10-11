{
  callPackage,
  package,
  repository,
}:
callPackage ../../lib/publish-snapshots.nix { inherit package repository; }
