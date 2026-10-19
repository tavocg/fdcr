{
  lib,
  stdenv,
  package,
  runCommand,
  gzip,
  patchelf,
}:
let
  revision = "${package.release}cr${package.crRevision}";
  rpmRevision = "${package.rpmRelease}cr${package.crRevision}";
  alternative = if package.pname == "opensc" then "opensc-git" else "opensc";
  multiarch = if stdenv.hostPlatform.isAarch64 then "aarch64-linux-gnu" else "x86_64-linux-gnu";
  payload =
    profile:
    let
      apt = builtins.elem profile [
        "jammy"
        "noble"
        "debian"
        "ubuntu2604"
      ];
      fedora = profile == "fedora";
      suse = profile == "opensuse";
      libdir =
        if apt then
          "/usr/lib/${multiarch}"
        else if fedora || suse then
          "/usr/lib64"
        else
          "/usr/lib";
      native = package.override {
        native = true;
        nativeLibdir = libdir;
        nativeSysconfdir = if apt then "/etc/opensc" else "/etc";
      };
      docdir = if suse then "/usr/share/doc/packages/opensc" else "/usr/share/doc/opensc";
    in
    runCommand "${package.pname}-payload-${profile}"
      {
        nativeBuildInputs = [
          gzip
          patchelf
        ];
      }
      ''
          mkdir -p "$out"
          cp -R ${native}/. "$out/"
          chmod -R u+w "$out"
          # Only the two upstream OpenSC trust anchors belong to this package.
        find "$out/etc/eac" -type f ! -name DESCHSMCVCA00001 ! -name DESRCACC100001 -delete
        mkdir -p "$out/usr/share/bash-completion"
        mv "$out${
          if apt then "/etc/opensc" else "/etc"
        }/bash_completion.d" "$out/usr/share/bash-completion/completions"
        # Development headers and private build inputs are not runtime package files.
          rm -rf "$out/usr/include" "$out/usr/share/licenses" "$out/usr/share/doc"
          mkdir -p "$out${docdir}"
          cp "$out/share/opensc-build/NEWS" "$out${docdir}/NEWS"
          ${lib.optionalString (!apt) ''
            cp "$out/share/opensc-build/README" "$out${docdir}/README"
          ''}
          ${lib.optionalString (apt || fedora) ''
            rm -f "$out${libdir}/libopensc.so" "$out${libdir}/libsmm-local.so"
            rm -rf "$out${libdir}/pkgconfig"
          ''}
          ${lib.optionalString apt ''
                  mkdir -p "$out/usr/share/doc/opensc/examples" "$out/usr/share/doc/opensc/html"
                  cp "$out/etc/opensc/opensc.conf" "$out/usr/share/doc/opensc/examples/opensc.conf.example"
                  cp ${native}/usr/share/doc/opensc/*.html "$out/usr/share/doc/opensc/html/"
                  cat "$out/share/opensc-build/COPYING" "$out/share/opensc-build/OpenPACE-COPYING" > "$out${docdir}/copyright"
                        cp "$out/share/opensc-build/README.md" "$out${docdir}/README.md"
                  ${lib.optionalString (profile != "jammy") ''gzip -n "$out${docdir}/README.md"''}
                  gzip -n "$out${docdir}/NEWS"
            mkdir -p "$out/usr/share/doc/opensc-pkcs11"
            cp "$out${docdir}/copyright" "$out/usr/share/doc/opensc-pkcs11/copyright"
            cp "$out${docdir}/NEWS.gz" "$out/usr/share/doc/opensc-pkcs11/NEWS.gz"
            readme=README.md${if profile == "jammy" then "" else ".gz"}
            cp "$out${docdir}/$readme" "$out/usr/share/doc/opensc-pkcs11/$readme"
            ln -s "$readme" "$out/usr/share/doc/opensc-pkcs11/README${if profile == "jammy" then "" else ".gz"}"
            ln -s "$readme" "$out${docdir}/README${if profile == "jammy" then "" else ".gz"}"
            ${lib.optionalString (profile != "debian") ''
              rm "$out${docdir}/$readme" "$out${docdir}/NEWS.gz"
              ln -s "../opensc-pkcs11/$readme" "$out${docdir}/$readme"
              ln -s ../opensc-pkcs11/NEWS.gz "$out${docdir}/NEWS.gz"
            ''}
            printf '%s\n' '${package.pname} (${package.version}-${revision}) unstable; urgency=medium' "" '  * OpenSC con soporte BCCR; fuente Git fijada en la snapshot.' > "$out${docdir}/changelog.Debian"
            gzip -n "$out${docdir}/changelog.Debian"
            cp "$out${docdir}/changelog.Debian.gz" "$out/usr/share/doc/opensc-pkcs11/changelog.Debian.gz"
            ${lib.optionalString (profile != "debian") ''
              rm "$out${docdir}/changelog.Debian.gz"
              ln -s ../opensc-pkcs11/changelog.Debian.gz "$out${docdir}/changelog.Debian.gz"
            ''}
            ${lib.optionalString (profile == "jammy") ''
              printf '%s\n' 'OpenSC actualizado desde Git con soporte BCCR.' | gzip -n > "$out${docdir}/NEWS.Debian.gz"
              cp -L "$out${libdir}/onepin-opensc-pkcs11.so" onepin.so
              rm "$out${libdir}/onepin-opensc-pkcs11.so"
              cp onepin.so "$out${libdir}/onepin-opensc-pkcs11.so"
            ''}
            ${lib.optionalString (profile == "ubuntu2604") ''
              mkdir -p "$out/usr/share/lintian/overrides"
              printf '%s\n' 'opensc-pkcs11: package-name-doesnt-match-sonames' > "$out/usr/share/lintian/overrides/opensc-pkcs11"
            ''}
                  mkdir -p "$out/etc/xdg/autostart"
                tar -xOf ${package.src} --wildcards "*/src/tools/pkcs11-register.desktop.in" | sed 's|@bindir@|/usr/bin|g' > "$out/etc/xdg/autostart/pkcs11-register.desktop"
                  mv "$out/usr/share/p11-kit/modules/opensc.module" "$out/usr/share/p11-kit/modules/opensc-pkcs11.module"
          ''}
          ${lib.optionalString fedora ''
                  cat "$out/share/opensc-build/COPYING" "$out/share/opensc-build/OpenPACE-COPYING" > "$out${docdir}/COPYING"
                  tar -xOf ${package.src} --wildcards "*/src/pkcs15init/README" > "$out${docdir}/README.pkcs15init"
                tar -xOf ${package.src} --wildcards "*/src/scconf/README.scconf" > "$out${docdir}/README.scconf"
                  rm -f "$out/usr/bin/opensc-notify" "$out/usr/bin/pkcs11-register" "$out/usr/share/man/man1/opensc-notify.1" "$out/usr/share/man/man1/pkcs11-register.1"
                  rm -rf "$out/usr/share/applications" "$out/etc/xdg"
            ln -s /etc/opensc.conf "$out/etc/opensc-${stdenv.hostPlatform.uname.processor}.conf"
          ''}
          ${lib.optionalString suse ''
            cp ${native}/usr/share/doc/opensc/*.html "$out${docdir}/"
            cp "$out/etc/opensc.conf" "$out${docdir}/opensc.conf"
            mkdir -p "$out/usr/share/licenses/opensc" "$out/etc/pkcs11/modules"
            cat "$out/share/opensc-build/COPYING" "$out/share/opensc-build/OpenPACE-COPYING" > "$out/usr/share/licenses/opensc/COPYING"
            mv "$out/usr/share/p11-kit/modules/opensc.module" "$out/etc/pkcs11/modules/opensc.module"
            rm -rf "$out/usr/share/p11-kit" "$out/usr/share/bash-completion" "$out/etc/xdg"
            rm -f "$out/usr/bin/opensc-notify" "$out${libdir}/libopensc.so"
          ''}
          ${lib.optionalString (profile == "arch") ''
            cp ${native}/usr/share/doc/opensc/*.html "$out${docdir}/"
            cp "$out/etc/opensc.conf" "$out${docdir}/opensc.conf"
            rm -f "$out${docdir}/README"
            cat "$out/share/opensc-build/OpenPACE-COPYING" >> "$out${docdir}/NEWS"
            rm -rf "$out/etc/xdg"
          ''}
          ${lib.optionalString
            (builtins.elem profile [
              "jammy"
              "noble"
            ])
            ''
              rm -f "$out/usr/bin/dtrust-tool" "$out/usr/share/man/man1/dtrust-tool.1" "$out/usr/share/bash-completion/completions/dtrust-tool"
              ${lib.optionalString (profile == "jammy") ''rm -rf "$out/etc/eac"''}
            ''
          }
          rm -f "$out/usr/bin/ctk-tool" "$out/usr/share/man/man1/ctk-tool.1" "$out/usr/share/bash-completion/completions/ctk-tool"
          rm -f "$out/usr/share/opensc/myeid_so_unblock.profile" "$out/usr/share/opensc/myeid_unblock_with_other_pin.profile" "$out/usr/share/opensc/myeid_unblocking_pin.profile"
          ${lib.optionalString (!suse) ''find "$out" -name '*.la' -delete''}
          rm -f "$out/usr/bin/lteid-tool" "$out/usr/share/man/man1/lteid-tool.1" "$out/usr/share/bash-completion/completions/lteid-tool"
        # Manual compression is a distro packaging step, not an upstream install step.
          find "$out/usr/share/man" -type f -name '*.[15]' -exec gzip -n {} +
          rm -rf "$out/share"
          find "$out" -type d -empty -delete
      '';
in
{
  options = {
    channels = [
      "jammy"
      "noble"
      "debian"
      "resolute"
      "fedora"
      "opensuse"
      "arch"
    ];
    payload = payload "arch";
    license = "LGPL-2.1-or-later AND GPL-3.0-or-later";
    maintainer = "FDCR maintainers <tavocg@users.noreply.github.com>";
    hooks.postInstall = "ldconfig";
    hooks.postRemove = "ldconfig";
    overrides = {
      jammy.payload = payload "jammy";
      noble.payload = payload "noble";
      debian.payload = payload "debian";
      resolute.payload = payload "ubuntu2604";
      opensuse.payload = payload "opensuse";
    };
    formats = {
      apt = {
        payload = payload "noble";
        depends = [
          "libc6 (>= 2.35)"
          "libc-bin"
          "libssl3 | libssl3t64"
          "libpcsclite1"
          "libreadline8 | libreadline8t64"
          "zlib1g"
          "libglib2.0-0 | libglib2.0-0t64"
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
        payload = payload "fedora";
        depends = [
          "glibc >= 2.35"
          "libcrypto.so.3()(64bit)"
          "libpcsclite.so.1()(64bit)"
          "libreadline.so.8()(64bit)"
          "libz.so.1()(64bit)"
          "libgio-2.0.so.0()(64bit)"
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
        version = "${package.version}+${revision}";
        release = package.release;
        depends = [
          "glibc>=2.35"
          "openssl"
          "pcsclite"
          "readline"
          "zlib"
          "glib2"
        ];
        recommends = [ "ccid: USB smart-card readers" ];
        conflicts = [ alternative ];
        provides = lib.optional (package.pname == "opensc-git") "opensc=${package.version}+${revision}";
      };
    };
  };
}
