{ system }:
let
  inherit (import ../../../lib/environments/2026-10-11.nix { inherit system; }) callPackage;
  builders = callPackage ../builders.nix { };
  pinFile = import ../../../lib/recipes/2026-10-11/pin-file.nix;
in
rec {
  builder = builders.autotools_2026_10_18;
  pname = "opensc-git";
  version = "0.27.1+git20261004.fc27ee8";
  rev = "fc27ee8768cb882fceb99535dce8b6a966534dcb";
  hash = "f623ea311d90fb9360681609dd96d8ba11476f503eda94de7a009033aa1e00b6";
  source = callPackage ./source.nix { inherit rev hash; };
  patches = [ (pinFile ../patches/fc27ee8-bccr-cards.patch) ];
  release = "2";
  rpmRelease = "12.fc45";
  crRevision = "0.1";
  publication.release = "${release}cr${crRevision}";
}
