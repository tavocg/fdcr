# fdcr (ALPHA)

Repositorio de dependencias para Firma Digital en Costa Rica.

Actualmente ofrece:

- `firmador`
- `firmador-git`
- `bccr-gaudi`
- `bccr-certs`
- `idopte-p11`
- `idopte-scmanager`

Consulta el [estado de la paquetería](doc/packages.md).

> [!WARNING]
> No usar en producción todavía, actualmente este repositorio se encuentra en
> fase de pruebas.

## Instalación

```sh
curl -fsSL https://tavocg.github.io/fdcr/install.sh | sudo sh
```

Para instalación manual, véase [doc/install.md](doc/install.md).

## Desarrollo

Los ZIP del proveedor están en `artifacts/`. `artifacts/artifacts.nix` declara sus
hashes y rutas internas, verifica cada ZIP y expone los árboles extraídos de
Idopte, GAUDI y los certificados por variante. Los paquetes consumen esas fuentes
mediante `callPackage` y aplican sus propios parches y reglas de instalación.

```sh
nix flake show
nix run .#build-public
```

Se genera la raíz del repositorio en `public/`. Para firmar los paquetes con
`gpg`, asigna `GPG_KEY_ID`.
