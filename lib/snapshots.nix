{ lib }:
{ snapshots, default }:
let
  packages = lib.mapAttrs (_: snapshot: snapshot.package.overrideAttrs (old: {
    passthru = (old.passthru or { }) // {
      repository = snapshot.publication or { };
    };
  })) snapshots;
in
assert lib.assertMsg (builtins.hasAttr default packages) "Unknown snapshot: ${default}";
packages.${default}.overrideAttrs (old: {
  passthru = (old.passthru or { }) // { snapshots = packages; };
})
