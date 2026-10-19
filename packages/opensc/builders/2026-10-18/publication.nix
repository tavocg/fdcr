{
  lib,
  stdenv,
  package,
  runCommand,
}:
let
  rpmRevision = "${package.rpmRelease}cr${package.crRevision}";
  revision = "${package.release}cr${package.crRevision}";
  native = package.override { native = true; };
  alternative = if package.pname == "opensc" then "opensc-git" else "opensc";
  multiarch = if stdenv.hostPlatform.isAarch64 then "aarch64-linux-gnu" else "x86_64-linux-gnu";
  payload =
    libdir:
    runCommand "${package.pname}-payload-${baseNameOf libdir}" { } ''
      mkdir -p "$out"
      cp -R ${native}/. "$out/"
      chmod -R u+w "$out"
      cp -R ${native.nativePace}/etc/opensc/eac/. "$out/etc/opensc/eac/"
      # Keep the administrator's configuration when installing/upgrading.
      mkdir -p "$out/usr/share/opensc"
      mv "$out/etc/opensc/opensc.conf" "$out/usr/share/opensc/opensc.conf"
      mkdir -p "$out${libdir}" "$out${libdir}/pkcs11"
      for file in opensc-pkcs11.so pkcs11-spy.so libopensc.so.13 libsmm-local.so.13; do
        ln -s "/usr/lib/opensc/$file" "$out${libdir}/$file"
      done
      ln -s /usr/lib/opensc/opensc-pkcs11.so "$out${libdir}/pkcs11/opensc-pkcs11.so"
    '';
in
{
  options = {
    payload = payload "/usr/lib";
    license = "LGPL-2.1-or-later AND GPL-3.0-or-later";
    maintainer = "FDCR maintainers <tavocg@users.noreply.github.com>";
    hooks.postInstall = ''
      if [ ! -e /etc/opensc/opensc.conf ]; then
        install -Dm644 /usr/share/opensc/opensc.conf /etc/opensc/opensc.conf
      fi
      ldconfig
    '';
    hooks.postRemove = "ldconfig";
    formats = {
      apt = {
        payload = payload "/usr/lib/${multiarch}";
        depends = [
          "libc6 (>= 2.35)"
          "libc-bin"
          "libssl3 | libssl3t64"
          "libpcsclite1"
          "libreadline8 | libreadline8t64"
          "zlib1g"
        ];
        recommends = [
          "pcscd"
          "libccid"
        ];
        conflicts = [
          alternative
          "opensc-pkcs11"
        ];
        provides = [
          "opensc-pkcs11 (= ${package.version}-${revision})"
        ]
        ++ lib.optional (package.pname == "opensc-git") "opensc (= ${package.version}-${revision})";
      };
      dnf = {
        release = rpmRevision;
        payload = payload "/usr/lib64";
        depends = [
          "glibc >= 2.35"
          "libcrypto.so.3()(64bit)"
          "libpcsclite.so.1()(64bit)"
          "libreadline.so.8()(64bit)"
          "libz.so.1()(64bit)"
        ];
        recommends = [ "pcsc-lite" ];
        conflicts = [
          alternative
          "opensc-libs"
        ];
        provides = [
          "opensc-libs = ${package.version}-${rpmRevision}"
          "libopensc.so.13()(64bit)"
          "libsmm-local.so.13()(64bit)"
        ]
        ++ lib.optional (package.pname == "opensc-git") "opensc = ${package.version}-${rpmRevision}";
      };
      pacman = {
        # pkgrel must be numeric; keep the CR revision in pkgver.
        version = "${package.version}+${revision}";
        release = package.release;
        depends = [
          "glibc>=2.35"
          "openssl"
          "pcsclite"
          "readline"
          "zlib"
        ];
        recommends = [ "ccid: USB smart-card readers" ];
        conflicts = [ alternative ];
        provides = lib.optional (package.pname == "opensc-git") "opensc=${package.version}+${revision}";
      };
    };
  };
}
