{
  lib,
  callPackage,
  package,
}:
let
  original = callPackage ../2026-10-11/publication.nix { inherit package; };
in
{
  options = original.options // {
    channels = [
      "jammy"
      "noble"
      "fedora"
      "opensuse"
      "arch"
    ];
    # SUSE Java providers do not use Fedora's epoch 1.
    overrides.opensuse.depends = map (lib.replaceStrings [ "1:" ] [ "" ]) package.dependencies.dnf;
  };
}
