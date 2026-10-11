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
  version = "2.0.0+git20260908.4b6803d";
  rev = "4b6803db37edbe13b535b6a06afc97657ddf0960";
  hash = "sha256-2zVxEz4MovGk05fmOFn2d5c0yc5g0Xth58SL9CCwfl4=";
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
