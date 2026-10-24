# Windows 11 x64

FDCR genera MSI de `firmador`, `firmador-git`, `opensc` y `opensc-git` desde
los mismos snapshots que los paquetes Linux. Se publican en el canal `win`,
con el alias `windows11`, junto con `install.ps1` y un catálogo SHA-256.

```powershell
Invoke-WebRequest 'https://tavocg.github.io/fdcr/install.ps1' -OutFile install.ps1
.\install.ps1 -Package opensc
.\install.ps1 -Package firmador
```

Para las variantes Git, usa `opensc-git` y `firmador-git`. `-Silent` solicita
instalación sin interfaz. Estos MSI requieren permisos de administrador:
instalan en `Program Files\FDCR` y usan registro por máquina. No admiten
`-Scope User`. No están firmados con Authenticode; `install.ps1` comprueba su
SHA-256 contra el catálogo HTTPS.

OpenSC estable y Git son alternativas: instalar uno reemplaza al otro. Ambos
instalan el módulo `Program Files\FDCR\opensc\bin\opensc-pkcs11.dll`, sus
herramientas, perfiles y configuración. Incluyen OpenSSL y OpenPACE; el módulo
PKCS#11 enlaza estáticamente el núcleo de OpenSC para poder cargarlo desde otras
aplicaciones. Este empaquetado no instala el minidriver de Windows.

Firmador incluye Java 25 para Windows, un lanzador nativo y un acceso directo.
No requiere instalar Java aparte. El lanzador utiliza el OpenSC de FDCR; se puede
seleccionar otra instalación de OpenSC con `LIBASEP11`. Firmador y Firmador Git pueden coexistir.
La versión estable registra el protocolo `firmador:`; Git no lo reemplaza.
Las actualizaciones del runtime incluido requieren reconstruir el MSI.

## Diagnóstico

Si aparece `Unable to access jarfile /C:/Program Files/FDCR/firmador/firmador.jar`,
la instalación está completa pero una versión anterior de Firmador 1.9.8 se
relanzaba con una ruta tipo URL. Actualice al MSI con release 3 o superior.

El lanzador comprueba OpenSC antes de iniciar Java en
`%ProgramW6432%\FDCR\opensc\bin\opensc-pkcs11.dll`, o en la ruta indicada por
`LIBASEP11`. Si el archivo falta, muestra un mensaje en vez del error de Java.
Para verificar la instalación:

```powershell
Get-Item "$env:ProgramFiles\FDCR\opensc\bin\opensc-pkcs11.dll"
& "$env:ProgramFiles\FDCR\opensc\bin\pkcs11-tool.exe" --list-slots
Get-ChildItem "$env:ProgramFiles\FDCR\firmador"
```

## Construcción y validación en Linux

```sh
nix build .#firmador-msi .#firmador-git-msi .#opensc-msi .#opensc-git-msi
nix build .#checks.x86_64-linux.windows
nix run .#build-public
```

Los atributos `*-msi` producen archivos MSI. `build-public` publica los cuatro
en `public/win/`. FDCR genera también `public/win/index.html` desde
`catalog.json`, con enlaces a todas las versiones, revisiones y arquitecturas
publicadas. Es HTML sin CSS, JavaScript ni etiquetas `<meta>`; no redirige ni
duplica los MSI. Esta página es específica de FDCR y se regenera al ejecutar
`nix run .#build-public`.

La construcción y publicación Windows se exponen desde
`x86_64-linux`; las salidas Linux de otras arquitecturas se conservan.

Las particularidades están en los builders `2026-10-19` de `packages/firmador`
y `packages/opensc`; las variantes Git reutilizan esos builders. Cada snapshot
sigue declarando una sola vez fuente, versión y parches. El builder añade
`windowsInstallerOptions`, que consume `metarepo.mkMsiInstaller`. El generador
MSI, accesos directos, registro y catálogo son responsabilidad de metarepo.
No hay un catálogo separado de versiones Windows.

Se tomó como referencia la compilación Windows de OpenSC (MSVC/NMake/WiX) y se
reutiliza su soporte Autotools/MinGW para construir desde Linux. El empaquetado
compartido usa wixl, sin duplicar el instalador completo de upstream.

La comprobación Linux extrae los MSI, inspecciona sus tablas, identidad de
actualización, arquitectura PE y dependencias del módulo PKCS#11, y verifica el
JAR y runtime incluidos. No ejecuta los binarios ni certifica instalación o firma
con tarjeta en Windows.
