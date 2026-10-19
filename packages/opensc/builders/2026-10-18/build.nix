{
  lib,
  stdenv,
  opensc,
  openpace,
  pcsclite,
  openssl,
  readline,
  zlib,
  autoreconfHook,
  pkg-config,
  libxslt,
  docbook_xsl,
  patchelf,
  pname,
  version,
  src,
  patches,
  release,
  rpmRelease,
  crRevision,
  native ? false,
}:
let
  compat = import ./compat.nix {
    inherit openpace;
    system = stdenv.hostPlatform.system;
  };
  runtime =
    if native then
      compat.pkgs
    else
      {
        inherit
          stdenv
          pcsclite
          openssl
          readline
          zlib
          ;
      };
  crypto = if native then runtime.openssl_3 else openssl;
  pace = if native then compat.openpace else openpace;
  prefix = if native then "/usr" else placeholder "out";
  libdir = if native then "/usr/lib/opensc" else "${prefix}/lib";
  config = if native then "/etc/opensc" else "${prefix}/etc/opensc";
in
runtime.stdenv.mkDerivation {
  inherit pname version src;
  patches = lib.optionals (version == "0.27.1") opensc.patches ++ patches;
  nativeBuildInputs =
    if native then
      [
        compat.pkgs.autoreconfHook
        compat.pkgs.pkg-config
        compat.pkgs.libxslt
        compat.pkgs.patchelf
      ]
    else
      [
        autoreconfHook
        pkg-config
        libxslt
        patchelf
      ];
  buildInputs = [
    crypto
    pace
    runtime.pcsclite
    runtime.readline
    runtime.zlib
  ];
  NIX_CFLAGS_COMPILE = "-Wno-error";
  PCSC_CFLAGS = "-I${lib.getDev runtime.pcsclite}/include/PCSC";
  configureFlags = [
    "--prefix=${prefix}"
    "--libdir=${libdir}"
    "--sysconfdir=${config}"
    "--localstatedir=/var"
    "--disable-static"
    "--disable-notify"
    "--enable-openpace"
    "--enable-sm"
    "--enable-pcsc"
    "--enable-openssl"
    "--enable-zlib"
    "--enable-readline"
    "--enable-man"
    "--disable-doc"
    "--disable-integration-tests"
    "--with-xsl-stylesheetsdir=${docbook_xsl}/xml/xsl/docbook"
    "--with-pcsc-provider=${
      if native then "libpcsclite.so.1" else "${lib.getLib pcsclite}/lib/libpcsclite.so.1"
    }"
    "--enable-cvcdir=${config}/eac/cvc"
    "--enable-x509dir=${config}/eac/x509"
  ];
  installFlags = lib.optional native "DESTDIR=$(out)";
  doCheck = true;
  postInstall = ''
    root="$out${lib.optionalString native "/usr"}"
    install -Dm644 COPYING "$root/share/licenses/${pname}/COPYING"
    mkdir -p "$root/share/p11-kit/modules"
    printf 'module: ${libdir}/opensc-pkcs11.so\n' > "$root/share/p11-kit/modules/opensc.module"
    ${lib.optionalString native ''
      cp -L ${lib.getLib pace}/lib/libeac.so.3 "$out/usr/lib/opensc/libfdcr-eac.so.3"
      install -Dm644 ${pace.src}/COPYING "$root/share/licenses/${pname}/OpenPACE-COPYING"
    ''}
    find "$out" -name '*.la' -delete
  '';
  # Only the published payload uses the system loader and system libraries.
  postFixup = lib.optionalString native ''
    find "$out/usr/bin" "$out/usr/lib/opensc" -type f | while IFS= read -r file; do
      if patchelf --print-rpath "$file" >/dev/null 2>&1; then
        patchelf --set-rpath /usr/lib/opensc "$file"
        patchelf --replace-needed libeac.so.3 libfdcr-eac.so.3 "$file"
        if [ "''${file##*/}" = libfdcr-eac.so.3 ]; then
          patchelf --set-soname libfdcr-eac.so.3 "$file"
        fi
        if patchelf --print-needed "$file" | grep -q /nix/store/; then
          echo "Unexpected Nix library dependency: $file" >&2
          exit 1
        fi
        if patchelf --print-interpreter "$file" >/dev/null 2>&1; then
          patchelf --set-interpreter ${
            if stdenv.hostPlatform.isAarch64 then
              "/lib/ld-linux-aarch64.so.1"
            else
              "/lib64/ld-linux-x86-64.so.2"
          } "$file"
        fi
      fi
    done

  '';
  passthru = {
    inherit release rpmRelease crRevision;
    nativePace = pace;
  };
  meta = opensc.meta // {
    description = "OpenSC con soporte para tarjetas de firma digital de Costa Rica";
    platforms = import ../../systems.nix;
    mainProgram = "opensc-tool";
  };
}
