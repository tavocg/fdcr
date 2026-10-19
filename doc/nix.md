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
    # Suspendidos hasta restaurar los artifacts del BCCR:
    # certificates.enable = true;
    # gaudi.enable = true;
  };
  environment.systemPackages = [ fdcr.packages.${pkgs.stdenv.hostPlatform.system}.firmador ];
}
```

El módulo instala OpenSC y habilita `services.pcscd`. Los certificados y GAUDI
son opcionales; sus paquetes pueden sustituirse con `certificates.package` y
`gaudi.package`. GAUDI y los certificados se publican para `x86_64-linux`.

GAUDI y los certificados están temporalmente excluidos de la construcción y
publicación. Para reactivarlos, restaura los ZIP y sus referencias comentadas en
`artifacts/recipes/2026-10-11/ubuntu.nix`, y la lista de sistemas en
`packages/bccr-{gaudi,certs}/systems.nix`.
