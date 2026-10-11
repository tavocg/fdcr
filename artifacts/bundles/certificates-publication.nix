{ runCommand }:
let
  directories = {
    jammy = "/usr/local/share/ca-certificates/bccr";
    noble = "/usr/local/share/ca-certificates/bccr";
    fedora = "/usr/share/pki/ca-trust-source/anchors";
    arch = "/usr/share/ca-certificates/trust-source/anchors";
  };
in {
  independent = true;
  maintainer = "Banco Central de Costa Rica";
  license = "LicenseRef-BCCR-Certificate-Data";
  refreshCertificates = true;
  configure = pkg: channel: {
    # Root filenames are determined during conversion; avoid evaluating build outputs.
    payload = runCommand "bccr-certs-${pkg.version}-payload" { } ''
      mkdir -p "$out/usr/share" "$out${directories.${channel}}"
      cp -a ${pkg}/share/bccr-certs "$out/usr/share/"
      for certificate in ${pkg}/share/bccr-certs/pem/roots/*.crt; do
        install -m644 "$certificate" "$out${directories.${channel}}/bccr-$(basename "$certificate")"
      done
    '';
  };
}
