{ callPackage }:
let
  artifacts = callPackage ../../artifacts/artifacts.nix { };
in
callPackage ../../lib/artifact-snapshots.nix { } {
  revision = "26_08";
  artifact = artifacts.vendor."26_08";
  component = "bccr-certs";
  build = callPackage ./build.nix { };
}
