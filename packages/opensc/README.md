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

La publicación usa metarepo y los canales existentes. El payload nativo se
compila contra el ABI mínimo de Ubuntu 22.04 y carga las bibliotecas del sistema;
no necesita Nix instalado. Incluye una OpenPACE privada para evitar diferencias
de ABI entre distribuciones; OpenSSL se obtiene de las dependencias del sistema. `compat.nix` fija esa base de compilación. Las
bibliotecas propias residen en `/usr/lib/opensc`; la publicación agrega los
enlaces de compatibilidad y dependencias correspondientes a DEB, RPM y Arch.
El módulo se registra mediante el archivo estándar de p11-kit.

Las dos variantes son alternativas y reemplazan OpenSC vanilla y sus bibliotecas
separadas. En Fedora usa `dnf install --allowerasing opensc` o `opensc-git`.
