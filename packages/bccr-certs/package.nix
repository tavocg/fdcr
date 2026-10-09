{
  lib,
  stdenvNoCC,
  openssl,
  callPackage,
  ubuntuRelease ? "noble",
}:
let
  source = (callPackage ../../artifacts/artifacts.nix { }).${ubuntuRelease};
in
stdenvNoCC.mkDerivation {
  pname = "bccr-certs";
  version = "2026.08";
  src = source.certificates;
  nativeBuildInputs = [ openssl ];
  dontUnpack = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    originals="$src"
    pem="$out/share/bccr-certs/pem"
    mkdir -p "$out/share/bccr-certs" "$pem/certificates" "$pem/roots"
    : > "$pem/bundle.pem"
    : > "$pem/ca-bundle.pem"
    : > "$pem/roots.pem"
    found=false
    export LC_ALL=C
    for certificate in "$originals"/*; do
      [ -f "$certificate" ] || continue
      found=true
      temporary="$pem/certificate.tmp"
      if ! openssl x509 -inform PEM -in "$certificate" -out "$temporary" 2>/dev/null; then
        if ! openssl x509 -inform DER -in "$certificate" -out "$temporary"; then
          echo "error: cannot parse certificate $certificate" >&2
          exit 1
        fi
      fi
      fingerprint=$(openssl x509 -in "$temporary" -noout -fingerprint -sha256)
      fingerprint=$(printf '%s' "''${fingerprint#*=}" | tr -d ':')
      certificate_pem="$pem/certificates/$fingerprint.pem"
      if [ -f "$certificate_pem" ]; then
        rm -f "$temporary"
        continue
      fi
      mv "$temporary" "$certificate_pem"
      cat "$certificate_pem" >> "$pem/bundle.pem"
      constraints=$(openssl x509 -in "$certificate_pem" -noout -ext basicConstraints 2>/dev/null || true)
      case "$constraints" in
        *CA:TRUE*)
          cat "$certificate_pem" >> "$pem/ca-bundle.pem"
          subject=$(openssl x509 -in "$certificate_pem" -noout -subject -nameopt RFC2253)
          issuer=$(openssl x509 -in "$certificate_pem" -noout -issuer -nameopt RFC2253)
          if [ "''${subject#subject=}" = "''${issuer#issuer=}" ]; then
            cp "$certificate_pem" "$pem/roots/$fingerprint.crt"
            cat "$certificate_pem" >> "$pem/roots.pem"
          fi
          ;;
      esac
    done
    [ "$found" = true ] && [ -s "$pem/roots.pem" ] || {
      echo "error: no self-signed CA certificates found in $originals" >&2
      exit 1
    }
    runHook postInstall
  '';

  meta = {
    description = "Certificados de la jerarquía nacional de Firma Digital de Costa Rica";
    homepage = "https://www.soportefirmadigital.com/";
    license = lib.licenses.unfree;
    platforms = import ./systems.nix;
  };
}
