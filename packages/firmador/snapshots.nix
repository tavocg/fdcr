{ jdk21 }:
# Newest first: the first entry is the default package; all entries are published.
[
  {
    version = "1.9.8";
    release = "1";
    rev = "09953947a51d87c2a146189ec76b6c27ab6518a1";
    hash = "sha256-xdiVPjihRADPK4nG+WQHWsDzVYLCeN6ouQ6SDtjf1qQ=";
    mvnHash = "sha256-opTjZA50tInbAmfGT1rJI3cC0+dUdYrIh8ZWReVeKWA=";
    buildJdk = jdk21;
    compilerParameters = "-Dmaven.compiler.source=8 -Dmaven.compiler.target=8";
    javaDependencies = {
      apt = [ "default-jre | java8-runtime" ];
      dnf = [ "java >= 1:1.8.0" ];
      pacman = [ "java-runtime>=8" ];
    };
  }
]
