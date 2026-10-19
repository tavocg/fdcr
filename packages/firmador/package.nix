{
  lib,
  stdenv,
  metarepo,
  # Ruta de la biblioteca PKCS#11. Al sobreescribir con
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
      // {
        inherit pkcs11Module;
        # Firmador 1.9.8 no lee LIBASEP11, así que el lanzador exportaría una
        # variable que el JAR ignora. El parche la agrega (2.0.0+ ya la
        # soporta) y solo se aplica en Nix, cuando el envoltorio la exporta;
        patches = [
          ./patches/newer-release-only.patch
        ]
        ++ lib.optional (
          pkcs11Module != null && lib.versionOlder args.version "2.0.0"
        ) ./patches/1.9.8-libasep11.patch;
      }
    );
}
