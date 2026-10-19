{
  lib,
  package,
  repository,
}:
let
  # metarepo.mkPublication should accept per-snapshot formats, overrides and
  # payload builders. Currently snapshot.publication only merges flat mkPackage
  # options. Dispatch separately so a Rust snapshot can coexist with Java ones.
  publications = lib.mapAttrsToList (
    _: snapshot:
    let
      options = snapshot.nativePublication;
      publication = snapshot.snapshotMetarepo.mkPublication (
        {
          inherit repository;
          package = snapshot;
          channels =
            options.channels
              or (builtins.attrNames (lib.filterAttrs (_: config: !(config ? inherits)) repository.channels));
        }
        // builtins.removeAttrs options [ "artifactTransforms" ]
      );
    in
    {
      channels =
        let
          own = lib.mapAttrs (
            channel: artifacts: map ((options.artifactTransforms or { }).${channel} or (x: x)) artifacts
          ) publication.channels;
          # Distro-specific channels reuse existing packages unless the snapshot
          # explicitly supplies an artifact for that channel (as OpenSC does).
          inherited = lib.filterAttrs (
            name: config:
            config ? inherits && !(builtins.hasAttr name own) && builtins.hasAttr config.inherits own
          ) repository.channels;
        in
        own // lib.mapAttrs (_: config: own.${config.inherits}) inherited;
    }
  ) package.snapshots;
  channels = lib.unique (lib.concatMap (p: builtins.attrNames p.channels) publications);
in
{
  channels = lib.genAttrs channels (
    channel: lib.concatMap (p: p.channels.${channel} or [ ]) publications
  );
}
