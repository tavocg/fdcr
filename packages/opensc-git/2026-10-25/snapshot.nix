{ system }:
let
  original = import ../2026-10-18/snapshot.nix { inherit system; };
  pinFile = import ../../../lib/recipes/2026-10-11/pin-file.nix;
in
original
// {
  patches = [ (pinFile ../patches/fc27ee8-bccr-cards-2026-10-25.patch) ];
  crRevision = "0.2";
  publication.release = "${original.release}cr0.2";
}
