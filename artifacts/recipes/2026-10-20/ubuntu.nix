# Local vendor payloads; requires a checkout hydrated with git lfs pull.
{ lib, runCommand, dpkg }:
let
  pinFile = import ../../../lib/recipes/2026-10-11/pin-file.nix;
  # Jammy and Noble ship byte-identical certificates.
  certificates = pinFile ../../bccr-certs-26.08;
  sources = {
    jammy = ../../bccr/2026-10-20/jammy;
    noble = ../../bccr/2026-10-20/noble;
  };
in
{
  variants = lib.mapAttrs (release: source: {
    inherit certificates;
    gaudi = runCommand "fdcr-gaudi-${release}-30.0-extracted" {
      nativeBuildInputs = [ dpkg ];
      deb = pinFile (source + "/Agente GAUDI/agente-gaudi-30.0_amd64.deb");
    } ''
      dpkg-deb --extract "$deb" "$out"
      dpkg-deb --control "$deb" "$out/vendor-control"
      chmod -R go-w "$out"
    '';
  }) sources;
}
