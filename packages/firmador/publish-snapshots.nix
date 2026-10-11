{ lib, callPackage, metarepo, repository, package }:
let
  # Resolve format-specific Java dependencies separately for each snapshot.
  publications = map (snapshot: (callPackage ./publication.nix {
    inherit metarepo repository;
    package = snapshot;
  }).channels) (builtins.attrValues package.passthru.snapshots);
in
{
  channels = lib.zipAttrsWith (_: lib.concatLists) publications;
}
