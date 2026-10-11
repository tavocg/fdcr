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
        }
        // builtins.removeAttrs options [ "artifactTransforms" ]
      );
    in
    {
      channels = lib.mapAttrs (
        channel: artifacts: map ((options.artifactTransforms or { }).${channel} or (x: x)) artifacts
      ) publication.channels;
    }
  ) package.snapshots;
  channels = lib.unique (lib.concatMap (p: builtins.attrNames p.channels) publications);
in
{
  channels = lib.genAttrs channels (
    channel: lib.concatMap (p: p.channels.${channel} or [ ]) publications
  );
}
