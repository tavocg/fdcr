# Instalación y desinstalación en Docker

La matriz instala los paquetes publicados por el canal de cada distro, usando
APT, DNF, Zypper o Pacman con resolución de dependencias y ejecución de hooks.
Prueba primero `firmador` y `opensc`, y después `firmador-git` y `opensc-git`;
ambos ciclos incluyen `bccr-certs` y `bccr-gaudi`.

Verifica la versión instalada contra el archivo, los archivos registrados por el
gestor, certificados, ejecutable de GAUDI, autostart y lanzador de Firmador.
Ejecuta `opensc-tool --version`. Desinstala cada grupo (purge en APT) y comprueba
que desaparezcan los registros y todos los archivos y enlaces que poseían.
No prueba la GUI, el inicio de sesión de escritorio ni una tarjeta física.

```sh
nix build --impure --no-link --json --file tests/packages/build.nix > /tmp/fdcr-artifacts.json
nix eval --impure --json --file tests/packages/artifacts.nix > /tmp/fdcr-channels.json
python3 tests/packages/verify.py /tmp/fdcr-channels.json /tmp/fdcr-install-tests --images /tmp/fdcr-images.json
```

Sin `--images`, busca imágenes locales `fdcr-opensc-<distro>-x86_64:*`.
El archivo opcional es un mapa de distro a imagen Docker con Python 3 y los
repositorios nativos configurados. Targets: `jammy`, `noble`, `ubuntu2604`,
`debian13`, `fedora43`, `fedora44`, `fedora45`, `opensuse-leap160`,
`opensuse-tumbleweed`, `arch`, `linuxmint223` y `linuxmint7`.
Las imágenes de Mint pueden usar `linuxmintd/mint22.3-amd64:latest` y
`linuxmintd/lmde7-amd64:latest`. La identidad efectiva del sistema se registra en
cada resultado junto al identificador de imagen y las rutas de los artifacts.

Los contenedores son desechables. `--jobs` limita el paralelismo (2 por defecto).
Cada distro conserva `installation.log` y `result.json`; `summary.json` reúne
los resultados. Los artifacts se copian o enlazan dentro de la carpeta de
resultados y se montan en modo lectura. Cada repetición debe usar una carpeta
nueva para evitar reutilizar resultados o archivos de una ejecución anterior.
