# Recetas y snapshots

`fdcr` construye aplicaciones para Nix y publica paquetes APT, DNF y Pacman
mediante metarepo. La fuente, su extracción, la construcción y la publicación
son decisiones diferentes. Una snapshot registra esas decisiones completas.

Las fechas de directorio son **fechas de registro en fdcr**, no fechas deducidas
del ZIP ni versiones del fabricante. `rev26_08` no se interpreta: el nombre del
ZIP, sus rutas internas y su SHA-256 son literales en la receta del artifact.
La versión publicada sigue siendo, por ejemplo, `2026.08` o `6.23.50.5`.

```text
artifacts/
  archivo-del-fabricante.zip
  recipes/2026-10-11/ubuntu.nix       # extracción fija y metadata del DEB
packages/bccr-certs/
  snapshots.nix                     # catálogo; se publican las entradas activas
  builders.nix                      # catálogo de builders identificados
  2026-10-11/
    snapshot.nix                    # versión, revisión, builder y entorno
    source.nix                      # conecta cualquier fuente con el builder
    dependencies.nix                # dependencias de esta snapshot
  builders/2026-10-11/
    build.nix                       # contrato de construcción específico
    publication.nix                 # payload, integración y opciones nativas
lib/environments/2026-10-11.nix      # Nixpkgs y metarepo fijados con rev + narHash
```

## Agregar una versión desde un artifact

1. Guardar el archivo nuevo en `artifacts/`, sin sobrescribir uno existente, y
   agregarlo con Git LFS. Para otros tipos de binario, añadir su patrón a
   `.gitattributes` o usar `git lfs track`. Un flake input descargado desde GitHub
   solo trae el archivo puntero de LFS, nunca el contenido real, así que la receta
   lee el binario del endpoint LFS (paso 2); `git lfs pull` solo hace falta para
   inspeccionar los archivos localmente.
2. Crear una receta nueva en `artifacts/recipes/<fecha>/`. Inspeccionar las rutas,
   dependencias y scripts del instalador; fijar el hash y declarar explícitamente
   la extracción. Para artifacts guardados con LFS, obtener el binario con
   `lib/recipes/<fecha>/fetch-artifact.nix` (`owner`, `repo`, `rev`, `path` y el
   `sha256` del fabricante): descarga el contenido real desde
   `media.githubusercontent.com` y lo fija por contenido, de modo que la ruta en
   el store coincide con un checkout local con `git lfs pull` y las derivaciones
   históricas no cambian. Aislar archivos locales auxiliares (lanzadores, unidades
   systemd, `.desktop`) con `lib/recipes/2026-10-11/pin-file.nix` para conservar su
   referencia por contenido al construir desde un flake y al pasar por `toString`
   en las integraciones. Puede devolver un binario, un árbol de archivos o varios
   componentes. Los scripts del fabricante se inspeccionan, nunca se ejecutan
   durante la extracción. El catálogo `artifacts/artifacts.nix` es opcional para
   las conexiones directas; agregar nombres allí no modifica las recetas previas.
3. Crear `packages/<paquete>/<fecha>/snapshot.nix` y su `source.nix`. Se puede
   reutilizar el builder existente si se cumple su contrato, aun cuando la
   extracción sea completamente distinta. Cada snapshot declara sus dependencias.
4. Agregar una entrada en `snapshots.nix`:

   ```nix
   { system }:
   {
     "2026-10-11" = import ./2026-10-11/snapshot.nix { inherit system; };
     "2026-10-14" = import ./2026-10-14/snapshot.nix { inherit system; };
   }
   ```

El identificador ISO mayor es el paquete predeterminado para Nix; todas las
snapshots activas del catálogo se publican. Se pueden comentar entradas antiguas
en `snapshots.nix` para reducir el tamaño publicado, conservando sus directorios
y los registros de `tests/historical.json` para una futura reactivación.
El índice de Pacman
conserva una versión por nombre; las anteriores pueden instalarse con `pacman -U`
desde su archivo mientras la snapshot siga activa. Para varias incorporaciones el mismo día, usar sufijos
ordenados (`-01`, `-02`). Evitar repetir nombre, versión, revisión y arquitectura
nativos dentro del mismo canal: el gestor de paquetes no puede distinguirlos.

### Tamaño de la publicación

El [workflow 46 de GitHub](https://github.com/tavocg/fdcr/actions/runs/39187740921)
publicó correctamente el artifact `metarepo-pages` de **1 691 385 491 bytes**
(creado el 2026-10-19 a las 02:09 UTC), aunque mostró la advertencia de tamaño.
Se desactivó `firmador-git/2026-10-11-01` y se mantuvo activa
`2026-10-11-02` (`2.0.0+git20260908.a34e5b8`). Tras ejecutar
`nix run .#build-public`, los siete canales suman **1 333 240 076 bytes**.
El TAR generado con las opciones de `upload-pages-artifact@v5` ocupa
**1 333 360 640 bytes**; un ZIP con Deflate nivel 6, como el upload de Actions,
ocupa aproximadamente **1 329 343 871 bytes**. Firmas, índices y detalles del
ZIP de CI pueden variar ligeramente.

`deploy-pages@v5` compara el tamaño del artifact con **1 073 741 824 bytes**
(1 GiB). Todavía faltan reducir aproximadamente **255,6 MB** (243,8 MiB)
para evitar la advertencia. Desactivar esa snapshot por sí solo no basta.

Un ejemplo de nueva snapshot que reutiliza un builder:

```nix
{ system }:
let
  inherit (import ../../../lib/environments/2026-10-11.nix { inherit system; }) callPackage;
  builders = callPackage ../builders.nix { };
in {
  builder = builders.artifacts_2026_10_11;
  source = (callPackage ./source.nix { }).src;
  version = "2026.10";
  dependencies = import ./dependencies.nix;
  publication.release = "1";
}
```

Las conexiones de artifacts actuales devuelven `{ src = { jammy = ...;
noble = ...; }; }`; el registro selecciona `.src` para entregar al builder
únicamente los árboles, sin los atributos que añade `callPackage`. El builder
Java recibe directamente una derivación de fuente.

Si la fuente pasa a Git, `source.nix` puede usar `fetchgit` o
`fetchFromGitHub` con commit y hash fijos, y transformar su contenido al contrato
del builder. No necesita depender del catálogo de artifacts ni de una variante
Ubuntu. Si cambia el contrato, agregar otro builder.

## Cambiar de builder o de herramientas

Copiar la receta a un directorio nuevo y registrar otro identificador en
`builders.nix`. Las snapshots antiguas siguen seleccionando el identificador
anterior. La construcción y publicación se versionan juntas, incluidos
lanzadores, unidades systemd y archivos auxiliares.

`firmador` y `firmador-git` comparten `java_2026_10_11`; sus commits, hashes,
`mvnHash`, JDK, parámetros de compilación y dependencias están en cada snapshot.
Una versión Rust/C++ puede seleccionar otro builder y otra publicación, con
arquitecturas, dependencias, payload y canales propios. El contrato general es
una derivación con `overrideAttrs`; la adaptación común adjunta
`nativePublication` y `snapshotMetarepo` a su `passthru`.

Actualizar `flake.lock` no renueva las herramientas históricas: cada snapshot
importa un entorno con Nixpkgs y metarepo fijados. Para herramientas nuevas,
crear otro archivo en `lib/environments/` y seleccionarlo en la snapshot nueva.
No reemplazar las referencias del entorno existente.

## Conservar el historial

Los directorios de snapshots, artifacts y builders ya publicados son inmutables.
Los catálogos pueden desactivar entradas comentándolas; nunca redirigen un identificador anterior.
Una corrección, incluso de empaquetado, necesita una snapshot nueva y una
versión/revisión nativa que no colisione con las anteriores.

`tests/historical.json` registra las derivaciones Nix y las publicaciones nativas
históricas en ambas arquitecturas. Las entradas desactivadas conservan su registro;
se vuelven a comprobar al reactivarlas. `nix flake check` rechaza cambios de receta,
fuente, herramientas, dependencias o hooks que alteren esas derivaciones. No
regenerar las entradas existentes para aprobar un cambio. Se pueden añadir las
nuevas entradas al registrar nuevas snapshots. La comprobación también simula
el cambio de un builder Java a otro nativo con dependencias y canales distintos.

```sh
nix flake check
nix run .#build-public
```

Esto conserva las entradas de construcción bug-for-bug; no promete bytes
idénticos de ZIP/JAR/paquetes o índices que incorporan timestamps y firmas.
La disponibilidad futura de fuentes externas, cachés y herramientas también es
necesaria; conservar Git LFS y caches de Nix permite reconstruir sin depender
de que el fabricante conserve una descarga.

## Adaptaciones de los instaladores actuales

Se inspeccionaron los DEB Ubuntu 22/24 y el RPM RH9 de los tres ZIP originales.
Las extracciones conservan los campos de control y scripts en `vendor-control/`.

- Idopte: `lib.sh` y `Comandos.txt` instalan PC/SC y CCID. Las dependencias están
  separadas entre middleware y GUI; se conserva la activación por socket.
  `idocachesrv` permanece opcional mientras se comprueba su ejecución en primer
  plano. Metarepo reinicia el servicio si ya está activo y lo detiene al remover.
- SCManager: el `postinst` descomprime `xsd.bin` y genera dos archivos desktop.
  Se generan durante la construcción y quedan bajo control del gestor. Se
  agregaron las dependencias de la extensión Nautilus y las herramientas que
  actualizan cachés MIME/desktop, ejecutadas mediante hooks de metarepo.
  Se conserva la configuración OpenSSL del administrador y sus asociaciones
  predeterminadas; no se copian los borrados recursivos ni `killall` del proveedor.
- GAUDI: el `postinst` instala el menú y autostart. Esos archivos ya están en el
  payload; el gestor realiza instalación/remoción. Se incorporaron las
  dependencias adicionales declaradas por el fabricante. Las rutas de jpackage
  `app` y `runtime` todavía requieren una adaptación `%dir` para RPM.
- Certificados: los anchors y su distribución mantienen el diseño existente;
  `refreshCertificates` de metarepo actualiza confianza al instalar y remover,
  sustituyendo la modificación manual del spec RPM.

Los comentarios inmediatamente anteriores a las adaptaciones genéricas señalan
las extensiones propuestas a metarepo: opciones completas por snapshot, archivos por contenido y `%dir`.
Las pruebas de construcción no sustituyen las pruebas gráficas por distribución
registradas en [packages.md](packages.md).
