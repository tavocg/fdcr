{ pkgs, package }:
let
  native = import ./windows-build.nix { inherit pkgs package; };
in
{
  options = {
    name = package.pname;
    inherit (package) version;
    manufacturer = "FDCR";
    # Stable and Git are alternatives, with a shared installation/upgrade identity.
    family = "opensc";
    registry = [
      {
        key = "Software\\FDCR\\OpenSC";
        name = "ConfigFile";
        value = "[INSTALLDIR]etc\\opensc.conf";
      }
      {
        key = "Software\\FDCR\\OpenSC";
        name = "ProfileDir";
        value = "[INSTALLDIR]share\\opensc";
      }
    ];
    payload = pkgs.runCommand "${package.pname}-windows-payload-${package.version}" { } ''
      mkdir -p "$out/bin"
      find -L ${native} -type f \( -name '*.dll' -o -name '*.exe' \) -exec cp '{}' "$out/bin/" \;
      cp -R ${native}/etc ${native}/share "$out/"
      test -f "$out/bin/opensc-pkcs11.dll"
    '';
  };
}
