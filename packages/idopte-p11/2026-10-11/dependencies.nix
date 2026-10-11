{
  jammy = [
    "libc6 (>= 2.15)"
    "libgcc1 (>= 1:4.6)"
    "libstdc++6 (>= 4.6)"
    "libpcsclite1 (>= 1.7)"
    "libxml2 (>= 2.7.3)"
    "zlib1g (>= 1:1.2.3.4)"
    "pcscd"
    "libccid"
  ];
  noble = [
    "libc6 (>= 2.38)"
    "libstdc++6 (>= 13.2)"
    "libgcc-s1"
    "libpcsclite1 (>= 1.7)"
    "libxml2 (>= 2.7.3) | libxml2-idopte-compat"
    "zlib1g (>= 1:1.2.3.4)"
    "pcscd"
    "libccid"
  ];
  dnf = [
    "glibc"
    "libgcc"
    "libstdc++"
    "pcsc-lite-libs"
    "pcsc-lite"
    "libxml2"
    "zlib"
    "pcsc-lite-ccid"
  ];
  pacman = [
    "glibc"
    "gcc-libs"
    "pcsclite"
    "libxml2"
    "zlib"
    "ccid"
  ];
}
