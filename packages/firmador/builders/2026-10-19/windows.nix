{ pkgs, package }:
let
  java = pkgs.fetchurl {
    url = "https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25.0.4.1%2B1/OpenJDK25U-jre_x64_windows_hotspot_25.0.4.1_1.zip";
    sha256 = "4c95451cea98556def2c54f7782933f52a26d4a36bd85e1d59f0364464828b07";
  };
in
{
  options = {
    name = package.pname;
    inherit (package) version;
    manufacturer = "FDCR";
    launcher = "${package.pname}.exe";
    registry = pkgs.lib.optionals (package.pname == "firmador") [
      {
        key = "Software\\Classes\\firmador";
        value = "URL:Firmador";
      }
      {
        key = "Software\\Classes\\firmador";
        name = "URL Protocol";
        value = "";
      }
      {
        key = "Software\\Classes\\firmador\\shell\\open\\command";
        value = ''"[INSTALLDIR]firmador.exe" "%1"'';
      }
    ];
    payload =
      pkgs.runCommand "${package.pname}-windows-payload-${package.version}"
        {
          nativeBuildInputs = [
            pkgs.unzip
            pkgs.pkgsCross.mingwW64.stdenv.cc
          ];
        }
        ''
          mkdir "$out"
          unzip -q ${java} -d runtime
          cp -R runtime/* "$out/runtime"
          cp ${package}/share/${package.pname}/firmador.jar "$out/"
          cp ${package}/share/licenses/${package.pname}/COPYING "$out/"
          x86_64-w64-mingw32-gcc -Os -static -municode -mwindows ${./launcher.c} -lshell32 -o "$out/${package.pname}.exe"
        '';
  };
}
