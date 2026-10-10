{
  callPackage,
  jdk25,
  snapshot ? builtins.head (import ./snapshots.nix),
}:
callPackage ../firmador/package.nix {
  pname = "firmador-git";
  inherit (snapshot) version rev hash mvnHash;
  buildJdk = jdk25;
  compilerParameters = "-Dmaven.compiler.source=25 -Dmaven.compiler.target=25";
}
