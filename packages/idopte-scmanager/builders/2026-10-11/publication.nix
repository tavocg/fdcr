{ package }:
let
  # Vendor postinst/postrm refresh MIME/desktop caches. Keep that behavior,
  # without modifying global mimeapps.list or requiring sudo from root scripts.
  # Desktop MIME declarations already associate PKCS#7; user choices take priority.
  refresh = ''
    if command -v update-mime-database >/dev/null 2>&1; then
      update-mime-database /usr/share/mime
    fi
    if command -v update-desktop-database >/dev/null 2>&1; then
      update-desktop-database /usr/share/applications
    fi
  '';
in
{
  options = {
    payload = package;
    maintainer = "Idopte <support@idopte.fr>";
    license = "LicenseRef-Proprietary";
    hooks = {
      postInstall = refresh;
      postRemove = refresh;
    };
    # Omit vendor killall, recursive deletions of package/user trees and global
    # OpenSSL edits. Owned files are removed by the package manager; preserve data.
    formats = {
      apt.depends = package.dependencies.noble;
      dnf.depends = package.dependencies.dnf;
      pacman.depends = package.dependencies.pacman;
    };
    overrides.jammy = {
      payload = package.override { ubuntuRelease = "jammy"; };
      depends = package.dependencies.jammy;
    };
  };
}
