{ lib, callPackage, runCommand, metarepo, package, snapshots }:
let
  publications = map (snapshot: callPackage ./publication.nix {
    inherit metarepo;
    package = package.override { inherit snapshot; };
  }) snapshots;
in
{
  # Keep every declared snapshot downloadable, with the same channel metadata.
  channels = lib.mapAttrs (channel: current:
    runCommand "${package.pname}-${channel}-snapshots" {
      passthru.metarepo = current.passthru.metarepo;
    } ''
      mkdir -p "$out"
      ${lib.concatMapStringsSep "\n" (publication: ''
        cp ${publication.channels.${channel}}/* "$out/"
      '') publications}
    ''
  ) (builtins.head publications).channels;
}
