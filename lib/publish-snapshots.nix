{
  lib,
  pkgs,
  metarepo,
  package,
  repository,
}:
let
  # Keep historical Linux builders while metarepo handles snapshot selection
  # and channel inheritance for every platform in a single publication.
  publish = metarepo.mkPublication.override {
    mkPackage =
      args:
      (args._artifactTransform or (x: x)) (
        args._packageBuilder (
          builtins.removeAttrs args [
            "_packageBuilder"
            "_artifactTransform"
          ]
        )
      );
  };
in
publish {
  inherit repository;
  package = package // {
    passthru = (package.passthru or { }) // {
      inherit (package) snapshots;
    };
  };
  snapshotOptions =
    snapshot:
    let
      options = snapshot.nativePublication;
      resolve = value: if builtins.isFunction value then value snapshot else value;
      windows =
        repository.channels ? win
        && pkgs.stdenv.hostPlatform.system == "x86_64-linux"
        && snapshot ? windowsInstallerOptions;
    in
    builtins.removeAttrs options [ "artifactTransforms" ]
    // {
      _packageBuilder = snapshot.snapshotMetarepo.mkPackage;
      channels =
        (options.channels or (builtins.attrNames (
          lib.filterAttrs (_: config: !(config ? inherits) && config.format != "msi") repository.channels
        ))
        )
        ++ lib.optional windows "win";
      overrides = lib.recursiveUpdate (resolve (options.overrides or { })) (
        lib.mapAttrs (_: transform: { _artifactTransform = transform; }) (options.artifactTransforms or { })
      );
      formats =
        (resolve (options.formats or { }))
        // lib.optionalAttrs windows {
          msi = {
            _packageBuilder = metarepo.mkPackage;
            architecture = "x64";
            payload = pkgs.emptyDirectory;
            hooks = { };
            # Preserve the existing MSI catalog metadata.
            description = "";
            homepage = "";
            maintainer = "";
            license = "";
            installer = metarepo.mkMsiInstaller snapshot.windowsInstallerOptions;
          };
        };
    };
}
