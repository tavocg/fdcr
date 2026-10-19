{
  lib,
  stdenv,
  opensc,
  openpace,
  pcsclite,
  openssl,
  readline,
  zlib,
  glib,
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
  nativeLibdir ? "/usr/lib",
  nativeSysconfdir ? "/etc",
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
          glib
          ;
      };
  crypto = if native then runtime.openssl_3 else openssl;
  pace = if native then compat.openpace else openpace;
  prefix = if native then "/usr" else placeholder "out";
  libdir = if native then nativeLibdir else "${prefix}/lib";
  config = if native then nativeSysconfdir else "${prefix}/etc/opensc";
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
  ]
  ++ lib.optional native runtime.glib;
  NIX_CFLAGS_COMPILE = "-Wno-error";
  PCSC_CFLAGS = "-I${lib.getDev runtime.pcsclite}/include/PCSC";
  configureFlags = [
    "--prefix=${prefix}"
    "--libdir=${libdir}"
    "--sysconfdir=${config}"
    "--localstatedir=/var"
    "--disable-static"
    (if native then "--enable-notify" else "--disable-notify")
    "--enable-openpace"
    "--enable-sm"
    "--enable-pcsc"
    "--enable-openssl"
    "--enable-zlib"
    "--enable-readline"
    "--enable-man"
    (if native then "--enable-doc" else "--disable-doc")
    "--disable-integration-tests"
    "--with-xsl-stylesheetsdir=${docbook_xsl}/xml/xsl/docbook"
    "--with-pcsc-provider=${
      if native then "libpcsclite.so.1" else "${lib.getLib pcsclite}/lib/libpcsclite.so.1"
    }"
    "--enable-cvcdir=${if native then "/etc" else config}/eac/cvc"
    "--enable-x509dir=${if native then "/etc" else config}/eac/x509"
  ];
  installFlags = lib.optional native "DESTDIR=$(out)";
  doCheck = true;
  postInstall = ''
    root="$out${lib.optionalString native "/usr"}"
    install -Dm644 COPYING "$root/share/licenses/${pname}/COPYING"
    mkdir -p "$root/share/p11-kit/modules"
    printf 'module: ${libdir}/opensc-pkcs11.so\n' > "$root/share/p11-kit/modules/opensc.module"
    ${lib.optionalString native ''
      mkdir -p "$out/share/opensc-build"
      cp COPYING NEWS README* "$out/share/opensc-build/"
      cp ${pace.src}/COPYING "$out/share/opensc-build/OpenPACE-COPYING"
      cp -R ${pace}/etc "$out/"
    ''}
    ${
      if native && nativeLibdir == "/usr/lib64" then
        ''
          # SUSE ships libtool metadata. Keep it free of build-store references.
          find "$out" -name '*.la' -exec sed -i \
            -e 's/^dependency_libs=.*/dependency_libs=""/' \
            -e 's/^inherited_linker_flags=.*/inherited_linker_flags=""/' {} +
        ''
      else
        ''
          find "$out" -name '*.la' -delete
        ''
    }
  '';
  # Only the published payload uses the system loader and system libraries.
  postFixup = lib.optionalString native ''
    find "$out/usr/bin" "$out${libdir}" -type f | while IFS= read -r file; do
      if patchelf --print-rpath "$file" >/dev/null 2>&1; then
        patchelf --set-rpath ${libdir} "$file"
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
