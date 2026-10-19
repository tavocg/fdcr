{ system }:
{
  # Desactivada para reducir el artifact de Pages; se conserva la receta histórica.
  # "2026-10-11-01" = import ./2026-10-11-01/snapshot.nix { inherit system; };
  "2026-10-11-02" = import ./2026-10-11-02/snapshot.nix { inherit system; };
}
