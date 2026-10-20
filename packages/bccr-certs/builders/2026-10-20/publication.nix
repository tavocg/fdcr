{
  callPackage,
  package,
  runCommand,
}:
let
  original = callPackage ../2026-10-11/publication.nix { inherit package; };
  susePayload = runCommand "bccr-certs-opensuse-payload" { } ''
    mkdir -p "$out/usr/share/pki/trust/anchors"
    cp -a ${package}/share/bccr-certs "$out/usr/share/"
    for certificate in ${package}/share/bccr-certs/pem/roots/*.crt; do
      install -m644 "$certificate" "$out/usr/share/pki/trust/anchors/bccr-$(basename "$certificate")"
    done
  '';
in
{
  options = original.options // {
    channels = [
      "jammy"
      "noble"
      "fedora"
      "opensuse"
      "arch"
    ];
    overrides = original.options.overrides // {
      opensuse = {
        payload = susePayload;
        refreshCertificates = false;
        hooks.postInstall = "update-ca-certificates";
        hooks.postRemove = "update-ca-certificates";
      };
    };
  };
}
