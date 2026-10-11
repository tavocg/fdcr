# Each artifact defines its own preparation and reusable component metadata.
{ callPackage, fetchurl }:
{
  vendor."26_08" = callPackage ./bundles/extract.nix {
    revision = "26_08";
    record = import ./bundles/26_08;
  };
  # Debian's ABI-2 build does not depend on a distribution-specific ICU version.
  libxml2Compat = fetchurl {
    url = "https://deb.debian.org/debian/pool/main/libx/libxml2/libxml2_2.12.7+dfsg+really2.9.14-2.1+deb13u3_amd64.deb";
    hash = "sha256-4Ma2PORgKgNqUm9g/l5sFYZxBogFjZj8EAG5sxR7fv0=";
  };
}
