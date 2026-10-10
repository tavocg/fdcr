{
  metarepo,
  package,
  runCommand,
  writeText,
}:
let
  # The pinned metarepo API has no RPM scriptlet arguments. Extend only this
  # package's spec until those hooks are supported by the shared builder.
  mkDnfWithTrustRefresh = metarepo.mkDnf.override {
    writeText = name: contents: writeText name (contents + ''

      %posttrans
      /usr/bin/update-ca-trust extract

      %postun
      if [ "$1" -eq 0 ] && [ -x /usr/bin/update-ca-trust ]; then
        /usr/bin/update-ca-trust extract
      fi
    '');
  };
  jammyPackage = package.override { ubuntuRelease = "jammy"; };
  payload = packageData: anchorPath: runCommand "bccr-certs-payload" { } ''
    mkdir -p "$out/usr/share" "$out${anchorPath}"
    cp -a ${packageData}/share/bccr-certs "$out/usr/share/"
    for certificate in ${packageData}/share/bccr-certs/pem/roots/*.crt; do
      install -m644 "$certificate" "$out${anchorPath}/bccr-$(basename "$certificate")"
    done
  '';
  common = data: anchorPath: {
    payload = payload data anchorPath;
    name = "bccr-certs";
    version = data.version;
    release = "1";
    maintainer = "Banco Central de Costa Rica";
    description = data.meta.description;
    homepage = data.meta.homepage;
    license = "LicenseRef-BCCR-Certificate-Data";
  };
in
{
  channels = {
    jammy = metarepo.mkApt ((common jammyPackage "/usr/local/share/ca-certificates/bccr") // {
      architecture = "all";
      depends = [ "ca-certificates" ];
    });
    noble = metarepo.mkApt ((common package "/usr/local/share/ca-certificates/bccr") // {
      architecture = "all";
      depends = [ "ca-certificates" ];
    });
    fedora = mkDnfWithTrustRefresh ((common package "/usr/share/pki/ca-trust-source/anchors") // {
      architecture = "noarch";
      depends = [ "ca-certificates" ];
    });
    arch = metarepo.mkPacman ((common package "/usr/share/ca-certificates/trust-source/anchors") // {
      architecture = "any";
      depends = [ "ca-certificates-utils" ];
    });
  };
}
