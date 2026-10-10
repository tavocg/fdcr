{ jdk25 }:
# Newest first: the first entry is the default package; all entries are published.
[
  {
    version = "2.0.0+git20260908.a34e5b8";
    rev = "a34e5b87b62093b22de95a543cf7edd303ec2676";
    hash = "sha256-ykDHGr1jdAkClgCVPVEIQWyo9idxjFfOem9TD1S6t9I=";
    mvnHash = "sha256-X6hxe5v+w+0RtKYeAOjRy2HFetH8LeCBNauZQq+I928=";
    release = "1";
    buildJdk = jdk25;
    compilerParameters = "-Dmaven.compiler.source=25 -Dmaven.compiler.target=25";
    javaDependencies = {
      apt = [ "openjdk-25-jre | java25-runtime" ];
      dnf = [ "java >= 1:25" ];
      pacman = [ "java-runtime>=25" ];
    };
  }
  {
    version = "2.0.0+git20260908.4b6803d";
    rev = "4b6803db37edbe13b535b6a06afc97657ddf0960";
    hash = "sha256-2zVxEz4MovGk05fmOFn2d5c0yc5g0Xth58SL9CCwfl4=";
    mvnHash = "sha256-X6hxe5v+w+0RtKYeAOjRy2HFetH8LeCBNauZQq+I928=";
    release = "1";
    buildJdk = jdk25;
    compilerParameters = "-Dmaven.compiler.source=25 -Dmaven.compiler.target=25";
    javaDependencies = {
      apt = [ "openjdk-25-jre | java25-runtime" ];
      dnf = [ "java >= 1:25" ];
      pacman = [ "java-runtime>=25" ];
    };
  }
]
