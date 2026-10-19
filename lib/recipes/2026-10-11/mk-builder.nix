{
  lib,
  callPackage,
  metarepo,
}:
# metarepo could expose a builder adapter preserving snapshot-specific payload,
# per-format/channel publication options and the pinned publication toolchain.
{
  build,
  publication,
  windows ? null,
}:
args:
let
  package = callPackage build args;
in
package.overrideAttrs (old: {
  passthru =
    (old.passthru or { })
    // {
      nativePublication = (callPackage publication { inherit package; }).options;
      snapshotMetarepo = metarepo;
    }
    // lib.optionalAttrs (windows != null) {
      windowsInstallerOptions = (callPackage windows { inherit package; }).options;
    };
})
