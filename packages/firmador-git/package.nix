{ callPackage, metarepo }:
callPackage ../firmador/package.nix {
  inherit metarepo;
  pname = "firmador-git";
  snapshots = callPackage ./snapshots.nix { };
  default = "a34e5b8";
}
