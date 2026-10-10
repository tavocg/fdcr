{
  callPackage,
  snapshot ? builtins.head (callPackage ./snapshots.nix { }),
}:
callPackage ../firmador/package.nix {
  pname = "firmador-git";
  inherit snapshot;
}
