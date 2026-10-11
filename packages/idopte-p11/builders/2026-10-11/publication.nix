{ package }:
let
  pinFile = import ../../../../lib/recipes/2026-10-11/pin-file.nix;
in
{
  options = {
    payload = package;
    maintainer = "Idopte <support@idopte.fr>";
    license = "LicenseRef-Proprietary";
    # Vendor lib.sh/Comandos.txt installs PC/SC and CCID. Keep them in snapshot
    # dependencies. Socket activation replaces starting/enabling pcscd.service.
    # idocachesrv remains opt-in: foreground behavior is not yet validated.
    # metarepo handles the vendor restart/stop lifecycle for an already active
    # daemon, respecting policy-rc.d on APT, without enabling it on installation.
    systemd.units."idocachesrv.service" = {
      source = pinFile ./idocachesrv.service;
      restartOnUpgrade = true;
      stopOnRemove = true;
    };
    hooks.postInstall = ''
      if [ -d /run/systemd/system ]; then
        systemctl start pcscd.socket
      fi
    '';
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
