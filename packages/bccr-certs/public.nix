{
  lib,
  metarepo,
  package,
  runCommand,
  stdenvNoCC,
  openssl,
  unzip,
}:
let
  jammyPackage = import ./package.nix {
    inherit lib stdenvNoCC openssl unzip;
    sourceZip = ../idopte-p11/artifacts/sfd_ClientesLinux_DEB64_Ubuntu22_rev26_08.zip;
    sourceMd5 = "348e3c06ef5218542266bdf417c13e36";
    certPath = "sfd_ClientesLinux_DEB64_Ubuntu22_26_08/Firma Digital/Certificados";
  };
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
    fedora = metarepo.mkDnf ((common package "/usr/share/pki/ca-trust-source/anchors") // {
      architecture = "noarch";
      depends = [ "ca-certificates" ];
    });
    arch = metarepo.mkPacman ((common package "/usr/share/ca-certificates/trust-source/anchors") // {
      architecture = "any";
      depends = [ "ca-certificates-utils" ];
    });
  };
}
