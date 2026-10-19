{
  lib,
  stdenv,
  metarepo,
}:
let
  snapshots = import ./snapshots.nix { system = stdenv.hostPlatform.system; };
in
metarepo.mkSnapshots {
  inherit snapshots;
  default = lib.last (builtins.attrNames snapshots);
  source = snapshot: snapshot.source;
  build =
    args:
    args.builder (
      builtins.removeAttrs args [
        "builder"
        "source"
      ]
    );
}
