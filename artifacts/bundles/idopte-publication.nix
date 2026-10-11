{ runCommand }:
let
  common = {
    maintainer = "Idopte <support@idopte.fr>";
    license = "LicenseRef-Proprietary";
  };
in {
  idopte-scmanager = common;
  idopte-p11 = common // {
    systemd.units."idocachesrv.service" = ../../packages/idopte-p11/idocachesrv.service;
    # PC/SC activation remains a post-transaction action on Arch.
    configure = pkg: channel: {
      payload = if channel != "arch" then pkg else
        runCommand "idopte-p11-${pkg.version}-arch-payload" { } ''
          cp -a ${pkg}/. "$out/"
          chmod -R u+w "$out"
          install -Dm644 ${../../packages/idopte-p11/pcscd.hook} \
            "$out/usr/share/libalpm/hooks/90-idopte-pcscd.hook"
        '';
    };
  };
}
