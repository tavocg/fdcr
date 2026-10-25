{ system }:
{
  "2026-10-18" = import ./2026-10-18/snapshot.nix { inherit system; };
  "2026-10-25" = import ./2026-10-25/snapshot.nix { inherit system; };
}
