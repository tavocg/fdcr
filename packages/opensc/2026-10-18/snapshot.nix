{ system }:
let
  inherit (import ../../../lib/environments/2026-10-11.nix { inherit system; }) callPackage;
  builders = callPackage ../builders.nix { };
  pinFile = import ../../../lib/recipes/2026-10-11/pin-file.nix;
in
rec {
  builder = builders.autotools_2026_10_18;
  pname = "opensc";
  version = "0.27.1";
  rev = "19868984dc4dc697af6a86d65ab32a1f19a43ea4";
  hash = "a5031cba5e3f8958816d5390be5644fa5072fe79af6f3f2a46d8f0656e37df1c";
  source = callPackage ./source.nix { inherit rev hash; };
  patches = [ (pinFile ../patches/0.27.1-bccr-cards.patch) ];
  release = "2";
  rpmRelease = "12.fc45";
  crRevision = "0.1";
  publication.release = "${release}cr${crRevision}";
}
