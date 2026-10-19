{ pkgs, package }:
let
  cross = pkgs.pkgsCross.mingwW64;
  openssl = cross.openssl_3_6.override { static = true; };
  pace = cross.stdenv.mkDerivation {
    pname = "openpace-windows";
    version = pkgs.openpace.version;
    src = pkgs.openpace.src;
    nativeBuildInputs = [
      pkgs.autoreconfHook
      pkgs.pkg-config
      pkgs.gengetopt
      pkgs.help2man
    ];
    buildInputs = [ openssl ];
    LIBS = "-lws2_32 -lcrypt32 -lgdi32 -lbcrypt";
    # Upstream skips these link checks for MSVC; MinGW can perform them.
    postPatch = ''
      substituteInPlace configure.ac --replace-fail 'if test "''${WIN32}" != "yes";' 'if true;'
    '';
    configureFlags = [
      "--disable-shared"
      "--enable-static"
    ];
    buildPhase = "make -C src libeac.la";
    installPhase = ''
      make -C src install-libLTLIBRARIES install-nobase_includeHEADERS
      mkdir -p "$out/lib/pkgconfig"
      make libeac.pc
      cp libeac.pc "$out/lib/pkgconfig/"
    '';
    doCheck = false;
  };
in
cross.stdenv.mkDerivation {
  pname = "${package.pname}-windows";
  inherit (package) version src patches;
  nativeBuildInputs = [
    pkgs.autoreconfHook
    pkgs.pkg-config
    pkgs.libxslt
  ];
  buildInputs = [
    openssl
    pace
  ];
  LIBS = "-lws2_32 -lcrypt32 -lgdi32 -lbcrypt";
  configureFlags = [
    "--disable-man"
    "--disable-doc"
    "--disable-notify"
    "--disable-readline"
    "--disable-minidriver"
    "--enable-openpace"
    "--with-pkcs11-provider=opensc-pkcs11.dll"
  ];
  postPatch = ''
    substituteInPlace src/libopensc/Makefile.am --replace-fail \
      $'if ENABLE_MINIDRIVER\nnoinst_LTLIBRARIES = libopensc_static.la\nendif' 'noinst_LTLIBRARIES = libopensc_static.la'
    substituteInPlace src/pkcs11/Makefile.am --replace-fail '/src/libopensc/libopensc.la' '/src/libopensc/libopensc_static.la'
    sed -i '/^OPENSC_PKCS11_LIBS =/,/$(OPENPACE_LIBS)/{ /src\/common\/lib\(scdl\|compat\)\.la/d; }' src/pkcs11/Makefile.am
    substituteInPlace configure.ac --replace-fail \
      'OPENSC_VS_FF_COMPANY_NAME="VS_FF_LEGAL_COMPANY_NAME"' 'OPENSC_VS_FF_COMPANY_NAME="FDCR"'
  '';
  installFlags = [ "CVCDIR=$(out)/etc/eac/cvc" ];
  NIX_CFLAGS_COMPILE = "-Wno-error";
  OPENPACE_LIBS = "-L${pace}/lib -leac -L${openssl}/lib -lcrypto -lws2_32 -lcrypt32 -lgdi32 -lbcrypt";
  LDFLAGS = "-static-libgcc -static-libstdc++";
  enableParallelBuilding = true;
  doCheck = false;
  postInstall = ''
    mkdir -p "$out/share/licenses"
    cp COPYING "$out/share/licenses/OpenSC-COPYING"
    cp ${pace.src}/COPYING "$out/share/licenses/OpenPACE-COPYING"
    tar -xOf ${openssl.src} openssl-${openssl.version}/LICENSE.txt > "$out/share/licenses/OpenSSL-LICENSE"
  '';
}
