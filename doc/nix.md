# Uso con Nix

## Perfil y devShell

En `x86_64-linux`, los paquetes `idopte-scmanager`, `firmador` y `firmador-git`
incluyen el middleware `idopte-p11` adaptado a Nix. Cada aplicación se ejecuta en
un entorno FHS que proporciona `/usr/lib/SCMiddleware`, `/etc/idoss.conf` y
`/etc/idoss.lic`, sin instalar esos archivos en el host. Firmador recibe
`LIBASEP11` apuntando al middleware incluido.

Desde este repositorio:

```sh
nix profile install .#idopte-scmanager .#firmador
SCManager
firmador
```

O temporalmente:

```sh
nix develop .#scmanager --command SCManager
nix develop .#firmador --command firmador
nix develop .#firmador-git --command firmador-git
```

`nix develop` incluye SCManager y Firmador. También puedes usar
`nix run .#idopte-scmanager` o `nix run .#firmador`.

El host debe proporcionar una sesión gráfica, permitir los espacios de nombres
que usa Bubblewrap y tener `pcscd` funcionando con acceso al lector. En NixOS:

```nix
services.pcscd.enable = true;
```

El perfil y las devShells no instalan servicios, certificados en el almacén del
sistema ni la extensión de Nautilus. Para integrar esos componentes, consulta
[el módulo NixOS](#uso-en-nixos).

Los payloads originales, sus snapshots y publicaciones se conservan en
`legacyPackages.<system>`. Los paquetes de otras arquitecturas conservan el
comportamiento anterior; el middleware Idopte solo está disponible para x86_64.

## Uso en NixOS

El flake publica un módulo NixOS que adapta los paquetes nativos (APT/DNF/Pacman)
a NixOS. Las recetas publicadas no se modifican: el módulo reubica el árbol del
middleware, enlaza sus dependencias con `autoPatchelf` y envuelve SCManager en un
entorno FHS.

> [!NOTE]
> Solo `x86_64-linux`. El módulo afirma esta plataforma porque el middleware
> Idopte no se publica para otras arquitecturas.

### Importar el módulo

```nix
{
  inputs.fdcr.url = "github:tavocg/fdcr";

  outputs = { self, nixpkgs, fdcr, ... }: {
    nixosConfigurations.mi-equipo = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        fdcr.nixosModules.default
        {
          services.fdcr.enable = true;
        }
      ];
    };
  };
}
```

`nixosModules.default` es un alias de `nixosModules.fdcr`.

### Opciones

| Opción                                    | Por defecto                              | Descripción                                                     |
|-------------------------------------------|------------------------------------------|-----------------------------------------------------------------|
| `services.fdcr.enable`                    | `false`                                  | Activa el módulo.                                               |
| `services.fdcr.middleware.enable`         | según `scmanager`                        | Instala el middleware Idopte y su configuración en `/etc`.      |
| `services.fdcr.package`                   | middleware adaptado                      | Paquete del middleware. Archivos bajo `$out/lib/SCMiddleware`.  |
| `services.fdcr.pkcs11Module`              | `$package/lib/SCMiddleware/libidop11.so` | Biblioteca PKCS#11 para Firmador.                               |
| `services.fdcr.certificates.enable`       | `false`                                  | Instala las CA raíz de Firma Digital en el almacén del sistema. |
| `services.fdcr.certificates.package`      | `bccr-certs`                             | Paquete de certificados.                                        |
| `services.fdcr.gaudi.enable`              | `false`                                  | Instala el agente GAUDI y su inicio de sesión gráfico.          |
| `services.fdcr.gaudi.package`             | `bccr-gaudi`                             | Paquete del agente GAUDI.                                       |
| `services.fdcr.scmanager.enable`          | `false`                                  | Instala SCManager y su integración de escritorio.               |
| `services.fdcr.scmanager.package`         | `idopte-scmanager`                       | Payload nativo, envuelto en FHS por el módulo.                  |
| `services.fdcr.scmanager.nautilus.enable` | con GNOME                                | Habilita la extensión de SCManager para Nautilus.               |

Al activar `scmanager`, el módulo habilita el middleware de forma implícita.
`services.pcscd.enable` siempre se activa.

### Firmador y la biblioteca PKCS#11

Los paquetes `firmador` y `firmador-git` ya incluyen el middleware Idopte en un
entorno FHS, con su configuración y las rutas absolutas que necesita. Puedes
instalarlos directamente:

```nix
environment.systemPackages = [ fdcr.firmador ];
```

No necesitan activar el módulo completo, pero el host debe tener PC/SC habilitado:

```nix
services.pcscd.enable = true;
```

El argumento `pkcs11Module` sigue disponible para seleccionar otra biblioteca.
Firmador 1.9.8 recibe el backport de `LIBASEP11`; las publicaciones para otras
distribuciones conservan sus recetas nativas.

### Certificados

`bccr-certs` no expone `/etc/ssl/certs/bccr-roots.pem`. El módulo usa el conjunto
PEM del paquete:

```nix
security.pki.certificateFiles = [
  "${config.services.fdcr.certificates.package}/share/bccr-certs/pem/roots.pem"
];
```

### Ejemplo completo

```nix
{ inputs, pkgs, config, ... }:
let
  fdcr = inputs.fdcr.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [ inputs.fdcr.nixosModules.default ];

  services.fdcr = {
    enable = true;
    middleware.enable = true;
    certificates.enable = true;
    scmanager.enable = true;
  };

  environment.systemPackages = [ fdcr.firmador ];
}
```

### Notas

- El módulo crea `/usr/lib/SCMiddleware` con enlaces a `libt_ias.so` e
  `idocachesrv` mediante `systemd.tmpfiles`, porque el firmware espera esa ruta
  absoluta.
- El middleware necesita `libxml2.so.2` y el símbolo `xmlCtxtSetOptions`, que
  introdujo libxml2 2.13. Como `libxml2` (2.15) ya usa la ABI `libxml2.so.16`,
  el módulo enlaza `libxml2_13`.
- La extensión de Nautilus se activa por defecto con GNOME cuando Nautilus no
  está excluido. En otros escritorios, habilítala solo si Nautilus está
  instalado.
