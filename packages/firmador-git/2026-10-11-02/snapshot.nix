{ system }:
let
  inherit (import ../../../lib/environments/2026-10-11.nix { inherit system; }) callPackage pkgs;
  inherit (pkgs) jdk21 jdk25;
  builders = callPackage ../builders.nix { };
in
rec {
  builder = builders.java_2026_10_11;
  pname = "firmador-git";
  source = callPackage ./source.nix { inherit rev hash; };
  version = "2.0.0+git20260908.a34e5b8";
  rev = "a34e5b87b62093b22de95a543cf7edd303ec2676";
  hash = "sha256-ykDHGr1jdAkClgCVPVEIQWyo9idxjFfOem9TD1S6t9I=";
  mvnHash = "sha256-X6hxe5v+w+0RtKYeAOjRy2HFetH8LeCBNauZQq+I928=";
  publication.release = "1";
  buildJdk = jdk25;
  compilerParameters = "-Dmaven.compiler.source=25 -Dmaven.compiler.target=25";
  dependencies = {
    apt = [ "openjdk-25-jre | java25-runtime" ];
    dnf = [ "java >= 1:25" ];
    pacman = [ "java-runtime>=25" ];
  };
}
