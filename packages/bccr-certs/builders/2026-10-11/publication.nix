{ package, runCommand }:
let
  jammyPackage = package.override { ubuntuRelease = "jammy"; };
  payload =
    packageData: anchorPath:
    runCommand "bccr-certs-payload" { } ''
      mkdir -p "$out/usr/share" "$out${anchorPath}"
      cp -a ${packageData}/share/bccr-certs "$out/usr/share/"
      for certificate in ${packageData}/share/bccr-certs/pem/roots/*.crt; do
        install -m644 "$certificate" "$out${anchorPath}/bccr-$(basename "$certificate")"
      done
    '';
in
{
  options = {
    independent = true;
    maintainer = "Banco Central de Costa Rica";
    license = "LicenseRef-BCCR-Certificate-Data";
    # Use metarepo's native hooks instead of patching the RPM spec. Anchors keep
    # their existing paths; refresh trust on installation, upgrade and removal.
    refreshCertificates = true;
    formats = {
      apt = {
        payload = payload package "/usr/local/share/ca-certificates/bccr";
        depends = package.dependencies.apt;
      };
      dnf = {
        payload = payload package "/usr/share/pki/ca-trust-source/anchors";
        depends = package.dependencies.dnf;
      };
      pacman = {
        payload = payload package "/usr/share/ca-certificates/trust-source/anchors";
        depends = package.dependencies.pacman;
      };
    };
    overrides.jammy.payload = payload jammyPackage "/usr/local/share/ca-certificates/bccr";
  };
}
