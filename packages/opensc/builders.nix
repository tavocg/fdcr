{ callPackage }:
let
  mkBuilder = callPackage ../../lib/recipes/2026-10-11/mk-builder.nix { };
in
{
  autotools_2026_10_18 = mkBuilder {
    build = ./builders/2026-10-18/build.nix;
    windows = ./builders/2026-10-19/windows.nix;
    publication = ./builders/2026-10-18/publication.nix;
  };
}
