{ lib, callPackage }:
# Output contract for this builder: channel -> extracted idopte tree.
# Keep Noble for Fedora/Arch to preserve the currently tested payloads. The
# inspected RH9 RPM uses WebKit 4.0 and is not interchangeable with Noble's 4.1.
let
  bundles = (callPackage ../../../artifacts/recipes/2026-10-11/ubuntu.nix { }).variants;
in
{
  src = lib.mapAttrs (_: bundle: bundle.idopte) bundles;
}
