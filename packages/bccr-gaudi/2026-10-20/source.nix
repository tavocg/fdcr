{ lib, callPackage }:
# Output contract for this builder: channel -> extracted gaudi tree.
# Fedora and Arch reuse the Noble payload.
let
  bundles = (callPackage ../../../artifacts/recipes/2026-10-20/ubuntu.nix { }).variants;
in
{
  src = lib.mapAttrs (_: bundle: bundle.gaudi) bundles;
}
