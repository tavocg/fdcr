{ callPackage }:
# Append recipes; never redirect an existing name to a different extraction.
{
  ubuntu_2026_10_11 = (callPackage ./recipes/2026-10-11/ubuntu.nix { }).variants;
}
