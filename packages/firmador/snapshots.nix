{ system }:
{
  # Historical snapshots remain on disk; only the corrected publication is active.
  "2026-10-24" = import ./2026-10-24/snapshot.nix { inherit system; };
}
