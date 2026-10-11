# Snapshots y artifacts

Los snapshots de Idopte, GAUDI y certificados tienen dos campos: `package`, una
derivación Nix, y `publication`, opciones para `metarepo.mkPublication`.
Las recetas actuales están en `packages/<paquete>/build.nix` y reciben `src` y
`version`. Cada snapshot puede usar esa receta o elegir otra.

`lib/artifact-snapshots.nix` crea las entradas de un bundle conservando sus fuentes,
dependencias y canales. Para incorporar otro bundle, agrega otra llamada y une
los resultados con `//`. Mantén las llamadas de las revisiones anteriores.

También puedes unir esos snapshots con una entrada independiente. Por ejemplo,
tras definir `vendor` con los snapshots actuales y escribir una receta propia en
`from-source.nix`, el resultado de `snapshots.nix` puede ser:

```nix
vendor // {
  from-source = {
    package = callPackage ./from-source.nix { };
    publication = {
      channels = [ "noble" ];
      release = "1";
      formats.apt.depends = [ "libc6" "libpcsclite1" ];
    };
  };
}
```

La receta debe aportar el nombre, la versión y los metadatos del paquete, y
preparar el contenido para su instalación. Si produce un paquete Nix con rutas
`bin` y `share`, puede usar `metarepo.mkPayload` al definir `publication.payload`.
Para licencias sin identificador SPDX, especifica `publication.license`.

Un binario suelto puede registrarse con `fetchurl` en `artifacts/artifacts.nix`, o
usarse directamente desde la receta del snapshot. El registro no obliga a pasar
por el extractor de ZIP ni a crear variantes de Ubuntu.

`publication` permite dependencias por formato, overrides por canal y las
integraciones de certificados y systemd de metarepo. Además, el adaptador local
acepta `configure = package: channel: { ... };` para preparar el payload de cada
canal y `transform = format: archive: ...;` para ajustar el archivo empaquetado.
Estas funciones son opcionales; el bundle actual las usa para instalar los
certificados, activar PC/SC en Arch y registrar los directorios RPM de GAUDI.

La publicación recorre todos los snapshots compatibles con cada canal. Cambiar
`default` en `package.nix` selecciona el paquete Nix predeterminado; conserva la
publicación de las demás versiones.
