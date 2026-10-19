# OpenSC con soporte BCCR

`opensc` y `opensc-git` siguen la misma estructura que Firmador: cada entrada
fecha una snapshot con commit Git, hash, parches, builder y revisión. La variante
estable fija el commit del release; la variante Git fija un commit de master.

Para agregar otra snapshot, copia el directorio fechado, actualiza esos datos y
regístralo en `snapshots.nix`. Ambos paquetes comparten `builders.nix`; un cambio
de receta requiere agregar otro builder fechado, conservando los anteriores.
`release` y `crRevision` generan la revisión `Ncr0.1`. Pacman conserva `pkgrel=N`
y usa `+Ncr0.1` en `pkgver` para mantener una versión válida y posterior a vanilla.
`rpmRelease` conserva la mayor revisión vanilla del canal RPM compartido,
para que el paquete modificado se ordene después de los paquetes de las distros.

Desde la raíz del repositorio:

```sh
nix build path:.#opensc
nix build path:.#opensc-git
nix run path:.#build-public
```

La publicación usa metarepo y conserva las rutas de cada distribución:
Debian/Ubuntu usan el directorio multiarch; Fedora/openSUSE, `/usr/lib64`;
Arch, `/usr/lib`. El payload se compila contra el ABI mínimo de Ubuntu 22.04,
usa el cargador y OpenSSL del sistema, y no necesita Nix instalado. OpenPACE
se enlaza estáticamente para evitar incompatibilidades entre sus versiones
sin instalar una biblioteca privada. `compat.nix` fija la base de compilación.

La configuración, documentación, completaciones y registro PKCS#11 siguen las
ubicaciones vanilla. Los canales `debian`, `resolute` y `opensuse` permiten
respetar sus diferencias; para los paquetes preexistentes heredan los artefactos
de `noble` o `fedora`. El instalador selecciona el canal por distribución.
Las instalaciones anteriores que apuntaban a un canal compartido deben volver
a configurar el repositorio con el instalador o las instrucciones manuales.

Las dos variantes son alternativas y reemplazan OpenSC vanilla y sus bibliotecas
separadas. En Fedora usa `dnf install --allowerasing opensc` o `opensc-git`.

La matriz de instalación y comparación de archivos está en
[tests/opensc](../../tests/opensc/README.md), con sus excepciones de ABI y perfiles
retirados por upstream. Las pruebas de contenedor cubren x86_64; no requieren
una tarjeta física.
