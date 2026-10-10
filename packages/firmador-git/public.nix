{ lib, metarepo, runCommand, package }:
let
  snapshots = import ./snapshots.nix;
  publish = snapshot: import ../firmador/public.nix {
    inherit metarepo runCommand;
    package = snapshot;
    javaDependencies = {
      apt = [ "openjdk-25-jre | java25-runtime" ];
      dnf = [ "java >= 1:25" ];
      pacman = [ "java-runtime>=25" ];
    };
  };
  publications = map (snapshot: publish (package.override { inherit snapshot; })) snapshots;
in
{
  # Keep every declared snapshot downloadable, with the same channel metadata.
  channels = lib.mapAttrs (channel: current:
    runCommand "firmador-git-${channel}-snapshots" {
      passthru.metarepo = current.passthru.metarepo;
    } ''
      mkdir -p "$out"
      ${lib.concatMapStringsSep "\n" (publication: ''
        cp ${publication.channels.${channel}}/* "$out/"
      '') publications}
    ''
  ) (builtins.head publications).channels;
}
