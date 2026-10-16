{
  lib,
  stdenv,
  metarepo,
  # Ruta de la biblioteca PKCS#11 del middleware. Al sobreescribir con
  # `firmador.override { pkcs11Module = …; }` el lanzador exporta LIBASEP11.
  pkcs11Module ? null,
}:
let
  snapshots = import ./snapshots.nix { system = stdenv.hostPlatform.system; };
in
metarepo.mkSnapshots {
  inherit snapshots;
  # ISO registration dates, optionally with an ordered suffix. Latest is default.
  default = lib.last (builtins.attrNames snapshots);
  source = snapshot: snapshot.source;
  build =
    args:
    args.builder (
      (builtins.removeAttrs args [
        "builder"
        "source"
      ])
      // { inherit pkcs11Module; }
    );
}
