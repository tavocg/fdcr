# Inspect MSI databases and Windows PE files on Linux; never execute them.
{
  pkgs,
  metarepo,
  packages,
}:
let
  names = [
    "firmador"
    "firmador-git"
    "opensc"
    "opensc-git"
  ];
  installers = pkgs.lib.genAttrs names (
    name: metarepo.mkMsiInstaller packages.${name}.windowsInstallerOptions
  );
  inputs = pkgs.writeText "windows-installers.json" (builtins.toJSON installers);
in
if pkgs.stdenv.hostPlatform.system != "x86_64-linux" then
  pkgs.runCommand "windows-msi-unsupported" { } "touch $out"
else
  pkgs.runCommand "fdcr-windows-msi-inspection"
    {
      nativeBuildInputs = [
        pkgs.python3
        pkgs.msitools
        pkgs.binutils
      ];
    }
    ''
      mkdir "$out"
      python3 ${./windows.py} ${inputs} "$out/report.json"
    ''
