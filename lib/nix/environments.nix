{
  pkgs,
  packages,
  middlewarePackage ? null,
}:
let
  inherit (pkgs) lib;
  system = pkgs.stdenv.hostPlatform.system;
  middlewareData =
    if system == "x86_64-linux" then
      packages.idopte-p11
    else
      throw "FDCR: el middleware Idopte actualmente solo está disponible para x86_64-linux";

  # Middleware compatible con NixOS: se reubica el payload nativo y se enlazan
  # sus dependencias. Se usa la libxml2 del sistema con ABI `.so.2`, no la copia
  # privada de Debian que se publica en el canal Noble: esa versión (2.9.14) no
  # exporta `xmlCtxtSetOptions`, que el fabricante enlaza vía `libxmlsec1`.
  middleware =
    if middlewarePackage != null then
      middlewarePackage
    else
      pkgs.stdenvNoCC.mkDerivation {
        pname = "idopte-p11";
        inherit (middlewareData) version;
        dontUnpack = true;
        nativeBuildInputs = [ pkgs.autoPatchelfHook ];
        buildInputs = with pkgs; [
          stdenv.cc.cc.lib
          bzip2
          brotli
          expat
          fontconfig
          freetype
          libpng
          # El fabricante enlaza `libxml2.so.2` y `xmlCtxtSetOptions` (libxml2 ≥ 2.13).
          # `libxml2` (2.15) ya usa la ABI `.so.16`, por eso se fija `libxml2_13`.
          libxml2_13
          pcsclite
          xz
          zlib
        ];
        installPhase = ''
          runHook preInstall
          mkdir -p "$out"
          cp -a --no-preserve=mode,ownership ${middlewareData}/usr/. "$out/"
          cp -a --no-preserve=mode,ownership ${middlewareData}/etc "$out/etc"
          chmod -R u+w "$out"
          # `cp --no-preserve=mode` drops the executable bit. `libidop11.so` launches
          # `/usr/lib/SCMiddleware/idocachesrv`, so without it the exec fails with
          # EACCES and the middleware blocks forever waiting for the cache daemon,
          # which makes neither SCManager nor Firmador see the card.
          chmod u+x "$out/lib/SCMiddleware/idocachesrv"
          runHook postInstall
        '';
        meta = middlewareData.meta // {
          description = "Idopte smart card middleware for Costa Rica (NixOS)";
        };
      };

  # SCManager necesita rutas absolutas /usr/{lib,share}/SCMiddleware y un
  # entorno gráfico completo. Se envuelve el payload nativo en un FHS.
  scmanagerEnv =
    { base, nautilusSupport }:
    let
      payload = pkgs.stdenvNoCC.mkDerivation {
        pname = "idopte-scmanager-payload";
        inherit (base) version;
        dontUnpack = true;
        nativeBuildInputs = [ pkgs.autoPatchelfHook ];
        buildInputs = with pkgs; [
          stdenv.cc.cc.lib
          glib
          gtk3
          libappindicator-gtk3
          libnotify
          pcsclite
          webkitgtk_4_1
        ];
        preFixup = ''
          addAutoPatchelfSearchPath ${middleware}/lib/SCMiddleware
        '';
        installPhase = ''
          runHook preInstall
          mkdir -p "$out"
          cp -a --no-preserve=mode,ownership ${base}/usr/. "$out/"
          cp -a --no-preserve=mode,ownership ${base}/etc "$out/etc"
          chmod -R u+w "$out"
          # `cp --no-preserve=mode` drops the executable bit; without it the
          # launch script fails with "Permission denied" on exec.
          chmod u+x "$out/lib/SCMiddleware/SCManager"
          runHook postInstall
        '';
      };
    in
    pkgs.buildFHSEnv {
      pname = "idopte-scmanager";
      inherit (base) version;
      executableName = "SCManager";
      targetPkgs = p: [
        payload
        middleware
        p.bash
        p.coreutils
        p.gnugrep
        p.gnused
        p.gawk
        (lib.getBin p.openssl)
        (lib.getBin p.glib)
        p.gsettings-desktop-schemas
        p.procps
        p.lsof
        p.zenity
        p.xdg-utils
        p.xdg-user-dirs
        p.cacert
        (p.python3.withPackages (ps: [ ps.requests ]))
      ];
      multiPkgs = null;
      extraBuildCommands = middlewareEtc;
      runScript = pkgs.writeShellScript "scmanager-launch" ''
        if [ "''${1:-}" = "--nautilus-request" ]; then
          shift
          exec /usr/bin/python3 -c 'import json, sys; sys.path.insert(0, "/usr/share/SCMiddleware"); import crypto_common; crypto_common.send_request(json.loads(sys.argv[2]), sys.argv[1])' "$@"
        fi
        if [ "''${1:-}" = "--open-pkcs7" ]; then
          shift
          exec /usr/bin/python3 /usr/share/SCMiddleware/open_pkcs7.py "$@"
        fi
        exec /usr/lib/SCMiddleware/SCManager "$@"
      '';
      extraInstallCommands = ''
        mkdir -p "$out/share/applications" "$out/share/mime/packages" "$out/etc/xdg/autostart"
        cp ${base}/usr/share/applications/*.desktop "$out/share/applications/"
        cp ${base}/usr/share/mime/packages/*.xml "$out/share/mime/packages/"
        cp ${base}/etc/xdg/autostart/*.desktop "$out/etc/xdg/autostart/"
        substituteInPlace "$out/share/applications/SCManager.desktop" \
          "$out/etc/xdg/autostart/SCManager.desktop" \
          --replace-fail /usr/lib/SCMiddleware/SCManager "$out/bin/SCManager" \
          --replace-fail /usr/share/SCMiddleware/application.png "${middleware}/share/SCMiddleware/application.png"
        substituteInPlace "$out/share/applications/pkcs7.desktop" \
          --replace-fail '/usr/bin/python3 /usr/share/SCMiddleware/open_pkcs7.py' "$out/bin/SCManager --open-pkcs7"
      ''
      + lib.optionalString nautilusSupport ''
        mkdir -p "$out/share/nautilus-python/extensions" "$out/share/idopte-scmanager"
        cp ${base}/usr/share/nautilus-python/extensions/CryptoshellExtension.py \
          "$out/share/nautilus-python/extensions/"
        substituteInPlace "$out/share/nautilus-python/extensions/CryptoshellExtension.py" \
          --replace-fail /usr/share/SCMiddleware "$out/share/idopte-scmanager" \
          --replace-fail /usr/share/in_p11 "$out/share/idopte-scmanager" \
          --replace-fail 'import crypto_common' 'import idopte_crypto_common as crypto_common' \
          --replace-fail '"pidof"' '"${pkgs.procps}/bin/pidof"'
        substitute ${../../modules/scmanager-nautilus.py} "$out/share/idopte-scmanager/idopte_crypto_common.py" \
          --subst-var-by scmanager "$out/bin/SCManager" \
          --subst-var-by middleware "${middleware}" \
          --subst-var-by zenity "${pkgs.zenity}/bin/zenity"
      '';
      passthru = {
        inherit middleware nautilusSupport;
      };
      meta = {
        description = "Administrador gráfico SCManager de Idopte (NixOS)";
        homepage = "https://www.soportefirmadigital.com/";
        license = lib.licenses.unfree;
        platforms = [ "x86_64-linux" ];
        mainProgram = "SCManager";
      };
    };
  # Los archivos privados del FHS prevalecen sobre /etc del host.
  middlewareEtc = ''
    for name in idoss.conf idoss.lic; do
      ln -sfn ${middleware}/etc/$name "$out/etc/$name"
    done
  '';

  firmadorEnv =
    {
      base,
      pkcs11Module ? "${middleware}/lib/SCMiddleware/libidop11.so",
    }:
    let
      app = base.override { inherit pkcs11Module; };
      command = base.meta.mainProgram;
    in
    pkgs.buildFHSEnv {
      pname = base.pname;
      inherit (base) version;
      executableName = command;
      targetPkgs = p: [
        middleware
        p.bash
        p.coreutils
      ];
      multiPkgs = null;
      extraBuildCommands = middlewareEtc;
      runScript = "${app}/bin/${command}";
      extraInstallCommands = ''
        mkdir -p "$out/share"
        cp -a ${app}/share/applications ${app}/share/icons "$out/share/"
      '';
      passthru = {
        inherit middleware;
        nativePackage = base;
      };
      meta = base.meta // {
        platforms = [ "x86_64-linux" ];
      };
    };

in
{
  inherit middleware scmanagerEnv firmadorEnv;
}
