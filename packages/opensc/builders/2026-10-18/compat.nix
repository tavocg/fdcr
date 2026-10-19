# Build the native payload against the oldest supported glibc/OpenSSL ABI.
{
  system,
  openpace,
}:
let
  source = builtins.fetchTree {
    type = "github";
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b";
    narHash = "sha256-lHrKvEkCPTUO+7tPfjIcb7Trk6k31rz18vkyqmkeJfY=";
  };
  pkgs = import source.outPath { inherit system; };
in
{
  inherit pkgs;
  openpace =
    (openpace.override {
      stdenv = pkgs.stdenv;
      openssl = pkgs.openssl_3;
      autoreconfHook = pkgs.autoreconfHook;
      pkg-config = pkgs.pkg-config;
      help2man = pkgs.help2man;
      gengetopt = pkgs.gengetopt;
    }).overrideAttrs
      (old: {
        configureFlags = (old.configureFlags or [ ]) ++ [ "--sysconfdir=/etc/opensc" ];
        installFlags = [
          "CVCDIR=$(out)/etc/opensc/eac/cvc"
          "X509DIR=$(out)/etc/opensc/eac/x509"
        ];
      });
}
