{ callPackage, metarepo, repository, package }:
callPackage ../../lib/publication.nix {
  inherit metarepo repository package;
}
