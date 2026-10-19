{
  lib,
  pkgs,
  metarepo,
  packages,
  repository,
}:
lib.mapAttrs (
  _: package:
  lib.mapAttrs (
    _: snapshot:
    let
      publication = import ../lib/publish-snapshots.nix {
        inherit
          lib
          repository
          pkgs
          metarepo
          ;
        package = {
          snapshots.current = snapshot;
        };
      };
    in
    {
      package = snapshot.drvPath;
      channels = lib.mapAttrs (_: artifacts: map (a: a.drvPath) artifacts) publication.channels;
    }
  ) package.snapshots
) (builtins.removeAttrs packages [ "build-public" ])
