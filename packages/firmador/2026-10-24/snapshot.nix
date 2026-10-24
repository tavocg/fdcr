{ system }:
let
  original = import ../2026-10-20/snapshot.nix { inherit system; };
in
original
// {
  # Evita que Firmador 1.9.8 se relance con /C:/... en Windows.
  extraPatches = [
    ../patches/1.9.8-windows-relaunch.patch
  ];
  publication.release = "3";
}
