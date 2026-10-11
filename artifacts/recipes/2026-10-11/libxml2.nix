{ fetchurl }:
# Debian's ABI-2 build avoids distribution-specific ICU dependencies.
fetchurl {
  url = "https://deb.debian.org/debian/pool/main/libx/libxml2/libxml2_2.12.7+dfsg+really2.9.14-2.1+deb13u3_amd64.deb";
  hash = "sha256-4Ma2PORgKgNqUm9g/l5sFYZxBogFjZj8EAG5sxR7fv0=";
}
