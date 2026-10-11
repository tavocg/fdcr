{ lib }:
{
  maintainer = "Banco Central de Costa Rica";
  license = "LicenseRef-Proprietary";
  configure = pkg: _: { payload = pkg.passthru.payload; };
  # The vendor's jpackage launcher discovers these directories through rpm -ql.
  transform = format: package: if format != "dnf" then package else
    package.overrideAttrs (old: {
      buildCommand = assert lib.hasInfix "rpmbuild -bb " old.buildCommand;
        lib.replaceStrings [ "rpmbuild -bb " ] [ ''
          printf '%s\n' '%dir /opt/Agente-GAUDI/lib/app' \
            '%dir /opt/Agente-GAUDI/lib/runtime' >> "$TMPDIR/rpmbuild/filelist"
          rpmbuild -bb '' ] old.buildCommand;
    });
}
