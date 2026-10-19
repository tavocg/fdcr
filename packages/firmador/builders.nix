{ callPackage }:
let
  mkBuilder = callPackage ../../lib/recipes/2026-10-11/mk-builder.nix { };
in
{
  java_2026_10_11 = mkBuilder {
    build = ./builders/2026-10-11/build.nix;
    windows = ./builders/2026-10-19/windows.nix;
    publication = ./builders/2026-10-11/publication.nix;
  };
}
