# Verificación de OpenSC

La prueba compara los archivos de `opensc` y `opensc-git` con la unión de los
paquetes oficiales de ejecución: `opensc` y `opensc-pkcs11` en APT, `opensc` y
`opensc-libs` en Fedora, y `opensc` en openSUSE y Arch. No se incluyen paquetes
de desarrollo. Se inspecciona el contenido del archivo generado antes de instalarlo.
APT descarga y extrae los DEB originales de la versión instalada. En RPM se lee
el inventario, tipos y enlaces conservados en la cabecera original de la base de
datos RPM; en Arch se usa la lista de archivos de Pacman y sus enlaces instalados.
Los archivos de documentación excluidos de una imagen de contenedor siguen
contando en el inventario oficial.

Después instala el paquete sobre vanilla, comprueba que la versión instalada es
la del archivo, ejecuta `opensc-tool`, carga el módulo y llama a `C_Initialize` y
`C_Finalize`, comprueba el registro p11-kit y la configuración. No requiere una
tarjeta física. Comprueba rutas, tipos y destinos de enlaces; no exige igualdad
del contenido de archivos recompilados o de los metadatos de distribución.

```sh
nix build --impure --no-link --json --file tests/opensc/artifacts.nix > /tmp/opensc-artifacts.json
python3 tests/opensc/verify.py /tmp/opensc-artifacts.json /tmp/opensc-results --images /tmp/opensc-images.json
```

`opensc-images.json` es un mapa de los nombres siguientes a imágenes Docker con
OpenSC vanilla instalado: `jammy`, `noble`, `ubuntu2604`, `debian13`, `fedora43`,
`fedora44`, `fedora45`, `opensuse-leap160`, `opensuse-tumbleweed` y `arch`.
Las imágenes deben tener Python 3, p11-kit, el gestor de paquetes y sus repositorios
configurados; las RPM también necesitan `rpm2cpio` y `cpio`. En APT instala
`opensc opensc-pkcs11`; en Fedora `opensc opensc-libs`; en openSUSE y Arch `opensc`.
Sin `--images` se buscan las imágenes locales preparadas `fdcr-opensc-<nombre>-x86_64:*`.
Cada caso guarda `inventory.json`, los DEB originales cuando corresponda, y el
registro de instalación. El proceso falla si la instalación o la comparación falla.

Las únicas excepciones de inventario permitidas están explícitas en
`container-check.py`: los nombres SONAME de `libopensc` y `libsmm-local`, los
identificadores de compilación RPM y cinco perfiles antiguos de Ubuntu 22.04 que
upstream retiró antes de 0.27.1. No se crean enlaces que pretendan ofrecer el ABI
antiguo. Los archivos nuevos de master que no están en vanilla se excluyen del
payload. La prueba no permite otras rutas adicionales, faltantes o enlaces distintos.

Los resultados de la ejecución se resumen en `results.json`. La matriz comprueba
las diez distribuciones en x86_64; no certifica instalaciones aarch64 ni operaciones
con una tarjeta física.
