# Uso en NixOS

El flake publica un módulo NixOS que adapta los paquetes nativos (APT/DNF/Pacman)
a NixOS. Las recetas publicadas no se modifican: el módulo reubica el árbol del
middleware, enlaza sus dependencias con `autoPatchelf` y envuelve SCManager en un
entorno FHS.

> [!NOTE]
> Solo `x86_64-linux`. El módulo afirma esta plataforma porque el middleware
> Idopte no se publica para otras arquitecturas.

## Importar el módulo

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

## Opciones

| Opción                            | Por defecto            | Descripción                                                        |
|-----------------------------------|------------------------|--------------------------------------------------------------------|
| `services.fdcr.enable`            | `false`                | Activa el módulo.                                                  |
| `services.fdcr.middleware.enable` | según `scmanager`      | Instala el middleware Idopte y su configuración en `/etc`.         |
| `services.fdcr.package`           | middleware adaptado    | Paquete del middleware. Archivos bajo `$out/lib/SCMiddleware`.     |
| `services.fdcr.pkcs11Module`      | `$package/lib/SCMiddleware/libidop11.so` | Biblioteca PKCS#11 para Firmador.                |
| `services.fdcr.certificates.enable` | `false`              | Instala las CA raíz de Firma Digital en el almacén del sistema.    |
| `services.fdcr.certificates.package` | `bccr-certs`        | Paquete de certificados.                                           |
| `services.fdcr.gaudi.enable`      | `false`                | Instala el agente GAUDI y su inicio de sesión gráfico.             |
| `services.fdcr.gaudi.package`     | `bccr-gaudi`           | Paquete del agente GAUDI.                                          |
| `services.fdcr.scmanager.enable`  | `false`                | Instala SCManager y su integración de escritorio.                  |
| `services.fdcr.scmanager.package` | `idopte-scmanager`     | Payload nativo, envuelto en FHS por el módulo.                     |
| `services.fdcr.scmanager.nautilus.enable` | con GNOME     | Habilita la extensión de SCManager para Nautilus.                  |

Al activar `scmanager`, el módulo habilita el middleware de forma implícita.
`services.pcscd.enable` siempre se activa.

## Firmador y la biblioteca PKCS#11

El comando `firmador` del catálogo apunta a `/usr/lib/SCMiddleware/libidop11.so`.
En NixOS esa ruta no existe, así que hay que pasarle la biblioteca del paquete
adaptado con el argumento `pkcs11Module`:

```nix
{ inputs, pkgs, config, ... }:
let
  fdcr = inputs.fdcr.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  environment.systemPackages = [
    (fdcr.firmador.override {
      pkcs11Module = config.services.fdcr.pkcs11Module;
    })
  ];
}
```

`config.services.fdcr.pkcs11Module` es exactamente
`"${config.services.fdcr.package}/lib/SCMiddleware/libidop11.so"`, por lo que
también puedes escribir la ruta literal:

```nix
(fdcr.firmador.override {
  pkcs11Module = "${config.services.fdcr.package}/lib/SCMiddleware/libidop11.so";
})
```

El envoltorio de `firmador` exporta `LIBASEP11` apuntando a esa biblioteca y
delega en `.firmador-wrapped`. La variante `firmador-git` acepta el mismo
argumento. Firmador 1.9.8 todavía no leía `LIBASEP11`, así que en Nix se
parchea la fuente con ese backport (2.0.0+ ya lo incluye); como el parche solo
se aplica cuando se pasa `pkcs11Module`, las recetas publicadas para el resto
de canales no cambian.

## Certificados

`bccr-certs` no expone `/etc/ssl/certs/bccr-roots.pem`. El módulo usa el conjunto
PEM del paquete:

```nix
security.pki.certificateFiles = [
  "${config.services.fdcr.certificates.package}/share/bccr-certs/pem/roots.pem"
];
```

## Ejemplo completo

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

  environment.systemPackages = [
    (fdcr.firmador.override {
      pkcs11Module = config.services.fdcr.pkcs11Module;
    })
  ];
}
```

## Notas

- El módulo crea `/usr/lib/SCMiddleware` con enlaces a `libt_ias.so` e
  `idocachesrv` mediante `systemd.tmpfiles`, porque el firmware espera esa ruta
  absoluta.
- El middleware necesita `libxml2.so.2` y el símbolo `xmlCtxtSetOptions`, que
  introdujo libxml2 2.13. Como `libxml2` (2.15) ya usa la ABI `libxml2.so.16`,
  el módulo enlaza `libxml2_13` y no reutiliza la copia privada de
  `libxml2-idopte-compat` (2.9.14), que no exporta ese símbolo.
- La extensión de Nautilus se activa por defecto con GNOME cuando Nautilus no
  está excluido. En otros escritorios, habilítala solo si Nautilus está
  instalado.
