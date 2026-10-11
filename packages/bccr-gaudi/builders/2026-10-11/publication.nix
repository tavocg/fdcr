{ lib, package }:
{
  options = {
    payload = package.payload;
    maintainer = "Banco Central de Costa Rica";
    license = "LicenseRef-Proprietary";
    # Vendor postinst copies the desktop file/autostart and prerm calls xdg.
    # Both files are built into our payload; the package manager owns their removal.
    formats = {
      apt.depends = package.dependencies.noble;
      dnf.depends = package.dependencies.dnf;
      pacman.depends = package.dependencies.pacman;
    };
    overrides.jammy = {
      payload = (package.override { ubuntuRelease = "jammy"; }).payload;
      depends = package.dependencies.jammy;
    };
    # metarepo.mkDnf should expose declarative %dir entries. jpackage queries
    # rpm -ql to find app/runtime; metarepo still lists only files and symlinks.
    artifactTransforms.fedora =
      artifact:
      artifact.overrideAttrs (old: {
        buildCommand =
          assert lib.hasInfix "rpmbuild -bb " old.buildCommand;
          lib.replaceStrings
            [ "rpmbuild -bb " ]
            [
              ''
                printf '%s\n' '%dir /opt/Agente-GAUDI/lib/app' \
                  '%dir /opt/Agente-GAUDI/lib/runtime' >> "$TMPDIR/rpmbuild/filelist"
                rpmbuild -bb ''
            ]
            old.buildCommand;
      });
  };
}
