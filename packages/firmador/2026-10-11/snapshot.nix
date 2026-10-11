{ system }:
let
  inherit (import ../../../lib/environments/2026-10-11.nix { inherit system; }) callPackage pkgs;
  inherit (pkgs) jdk21 jdk25;
  builders = callPackage ../builders.nix { };
in
rec {
  builder = builders.java_2026_10_11;
  pname = "firmador";
  source = callPackage ./source.nix { inherit rev hash; };
  version = "1.9.8";
  publication.release = "1";
  rev = "09953947a51d87c2a146189ec76b6c27ab6518a1";
  hash = "sha256-xdiVPjihRADPK4nG+WQHWsDzVYLCeN6ouQ6SDtjf1qQ=";
  mvnHash = "sha256-opTjZA50tInbAmfGT1rJI3cC0+dUdYrIh8ZWReVeKWA=";
  buildJdk = jdk21;
  compilerParameters = "-Dmaven.compiler.source=8 -Dmaven.compiler.target=8";
  dependencies = {
    apt = [ "default-jre | java8-runtime" ];
    dnf = [ "java >= 1:1.8.0" ];
    pacman = [ "java-runtime>=8" ];
  };
}
