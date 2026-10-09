{
  metarepo,
  package,
}:
let
  publication = metarepo.mkApt {
    payload = package;
    name = package.pname;
    version = package.version;
    release = "1";
    architecture = "amd64";
    maintainer = "Idopte <support@idopte.fr>";
    inherit (package.meta) description homepage;
    license = "LicenseRef-Proprietary";
    depends = [
      "libc6 (>= 2.15)"
      "libgcc1 (>= 1:4.6)"
      "libstdc++6 (>= 4.6)"
      "libpcsclite1 (>= 1.7)"
      "pcscd"
      "libccid"
      "init-system-helpers"
    ];
  };
in
{
  channels.jammy = publication;
}
