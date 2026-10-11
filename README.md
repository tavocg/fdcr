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

Los artifacts se conservan en `artifacts/`. `artifacts/artifacts.nix` registra las
fuentes y su preparación reutilizable. Puede devolver un binario, un árbol extraído
o componentes con versiones, dependencias y opciones de publicación. La extracción
de los ZIP actuales vive en `artifacts/bundles/extract.nix`; sus datos y dependencias
se conservan por revisión en `artifacts/bundles/<revisión>/`.

Cada paquete decide qué versiones ofrecer en su `snapshots.nix`. Una entrada
contiene una derivación `package` y sus opciones `publication`. Puede usar los
artifacts registrados o construir el paquete con una receta independiente.
`lib/artifact-snapshots.nix` adapta los componentes preparados de un artifact a
ese formato sin hacer obligatorio su uso.

Para agregar otro bundle, conserva los ZIP y registros anteriores, registra su
preparación en `artifacts/artifacts.nix` y agrega sus snapshots a los paquetes que
lo utilicen. Registrar un artifact no lo publica automáticamente. SCManager
reutiliza la versión y revisión de Idopte de su propio artifact para exigir el
middleware correspondiente.

`lib/snapshots.nix` selecciona la versión predeterminada para Nix;
`lib/publication.nix` publica todos los snapshots en sus canales configurados.
Cada combinación `version-release` debe ser única por paquete y canal: si conserva
la versión pero cambia el contenido o sus dependencias, incrementa `release`.
Para seleccionar una versión Nix, usa
`package.override { default = "26_08-jammy"; }`.

Las rutas de instalación, los hooks y el ajuste RPM del GAUDI del proveedor están
en `artifacts/bundles/*-publication.nix`. Los snapshots que usan otra receta
definen sus propias opciones. Véase [cómo agregar snapshots](doc/snapshots.md).
Firmador conserva su construcción mediante `metarepo.mkSnapshots`.

```sh
nix flake show
nix run .#build-public
```

Se genera la raíz del repositorio en `public/`. Para firmar los paquetes con
`gpg`, asigna `GPG_KEY_ID`.
