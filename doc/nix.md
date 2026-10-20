# Uso con Nix

Los paquetes `firmador` y `firmador-git` usan OpenSC mediante `LIBASEP11`.

```sh
nix run .#firmador
nix develop .#firmador --command firmador
nix run .#firmador-git
```

Para seleccionar otra biblioteca PKCS#11:

```nix
fdcr.packages.x86_64-linux.firmador.override {
  pkcs11Module = "/ruta/a/opensc-pkcs11.so";
}
```

## Uso en NixOS

Agrega `fdcr.nixosModules.default` a los módulos del sistema:

```nix
{ pkgs, ... }: {
  services.fdcr = {
    enable = true;
    certificates.enable = true;
    gaudi.enable = true;
  };
  environment.systemPackages = [ fdcr.packages.${pkgs.stdenv.hostPlatform.system}.firmador ];
}
```

El módulo instala OpenSC y habilita `services.pcscd`. Los certificados y GAUDI
son opcionales; sus paquetes pueden sustituirse con `certificates.package` y
`gaudi.package`. GAUDI y los certificados se publican para `x86_64-linux`.

Los artifacts de GAUDI están en `artifacts/bccr/2026-10-20/`.
Los certificados compartidos están en `artifacts/bccr-certs-26.08/`.
La extracción está registrada en `artifacts/recipes/2026-10-20/ubuntu.nix`.
Se requiere `git lfs pull` antes de construir desde un checkout nuevo.
