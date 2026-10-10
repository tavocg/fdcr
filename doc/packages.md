# Paquetes

## `idopte-p11`

Middleware Idopte para tarjetas inteligentes y firma digital.

| Distro       | Canal    | Probado |
|--------------|----------|---------|
| Ubuntu 26.04 |          |         |
| Ubuntu 24.04 |          |         |
| Ubuntu 22.04 |          |         |
| Debian 13    |          |         |
| Fedora 45    |          |         |
| Fedora 44    |          |         |
| Fedora 43    |          |         |
| Arch Linux   |          |         |

Notas:

- [x] Arch: agregado un hook de pacman que inicia `pcscd.socket` después de instalar o actualizar `idopte-p11`, cuando systemd está activo. El socket activa `pcscd` cuando una aplicación lo necesita.
- [ ] Confirmar la activación inmediata en una instalación nueva de Arch, sin reiniciar.
- [x] Canal Noble: agregada la alternativa `libxml2-idopte-compat` para sistemas donde APT ya no ofrece `libxml2`. Conserva la ABI `libxml2.so.2` requerida por Idopte; `libxml2-16` no la sustituye. Se mantiene la preferencia por `libxml2` del sistema cuando está disponible.
- [ ] Confirmar instalación y firma en Ubuntu 26.04 con el paquete de compatibilidad.

## `idopte-scmanager`

Interfaz gráfica e integración de escritorio de Idopte. Depende de `idopte-p11`.

| Distro       | Canal    | Probado |
|--------------|----------|---------|
| Ubuntu 26.04 |          |         |
| Ubuntu 24.04 | noble    |         |
| Ubuntu 22.04 | jammy    |         |
| Debian 13    | noble    |         |
| Fedora 45    | fedora   |         |
| Fedora 44    | fedora   |         |
| Fedora 43    | fedora   |         |
| Arch Linux   | arch     |         |

Notas:

- [x] Agregado `StartupWMClass=SCManager` al lanzador y al inicio automático para asociar las ventanas con su ícono.
- [ ] Confirmar el ícono en la barra de tareas de Ubuntu 24.04 con el paquete actualizado.

## `firmador`

Firma de documentos con Firmador Libre.

| Distro       | Canal    | Probado |
|--------------|----------|---------|
| Ubuntu 26.04 |          |         |
| Ubuntu 24.04 | noble    |         |
| Ubuntu 22.04 | jammy    |         |
| Debian 13    | noble    |         |
| Fedora 45    | fedora   |         |
| Fedora 44    | fedora   |         |
| Fedora 43    | fedora   |         |
| Arch Linux   | arch     |         |

Notas:

- [x] Agregado `StartupWMClass=Firmador` al lanzador para asociar las ventanas de Java con su ícono.
- [ ] Confirmar el ícono en la barra de tareas de Ubuntu 24.04 con el paquete actualizado.
- [ ] Los desarrolladores indican que el firmador 1.9.8 soporta java desde la versión 8, pero que el 2.0.0 requiere java 25 en adelante.
      Lo ideal sería empaquetar 1.9.8 en firmador y ofrecer 2.0.0 con firmador-git (y poner de version 2.0.0+gitYYYYMMDD.abbrevhash-1) y requerir java 25 en adelante para ese.
      Cuando eventualmente tengamos 2.0.0, entonces ya ponemos esa versión dentro de firmador y no de firmador-git

## `bccr-gaudi`

Agente GAUDI del Banco Central de Costa Rica.

| Distro       | Canal    | Probado |
|--------------|----------|---------|
| Ubuntu 26.04 |          |         |
| Ubuntu 24.04 | noble    |         |
| Ubuntu 22.04 | jammy    |         |
| Debian 13    | noble    |         |
| Fedora 45    | fedora   |         |
| Fedora 44    | fedora   |         |
| Fedora 43    | fedora   |         |
| Arch Linux   | arch     |         |

Notas:

- [x] Fedora: registrados explícitamente `/opt/Agente-GAUDI/lib/app` y `/opt/Agente-GAUDI/lib/runtime` en el RPM. El lanzador de jpackage busca esos directorios en `rpm -ql`; su ausencia causaba los errores al localizar `Agente-GAUDI.cfg` y la JVM integrada. No requiere instalar otro Java ni cambiar el directorio de trabajo.
- [x] Agregado `StartupWMClass=bccr.principal.InicializadorDeActualizacion` al lanzador y al inicio automático para asociar las ventanas de JavaFX con su ícono. Eliminado el campo opcional `Version`, que identifica la versión del formato `.desktop`, no la de GAUDI.
- [ ] Confirmar el arranque en Fedora y el ícono en la barra de tareas de Ubuntu 24.04 con el paquete actualizado.
- [ ] Error al instalar gaudi en ubuntu:
      ```
      sudo apt install bccr-gaudi
      The following packages were automatically installed and are no longer required:
        linux-headers-7.0.0-30                   linux-modules-7.0.0-30-generic
        linux-headers-7.0.0-30-generic           linux-tools-7.0.0-30
        linux-image-unsigned-7.0.0-30-generic    linux-tools-7.0.0-30-generic
        linux-main-modules-zfs-7.0.0-30-generic
      Use 'sudo apt autoremove' to remove them.

      Installing:
        bccr-gaudi

      Installing dependencies:
        libccid  pcscd

      Summary:
        Upgrading: 0, Installing: 3, Removing: 0, Not Upgrading: 72
        Download size: 70.6 MB
        Space needed: 486 kB / 13.3 GB available

      Continue? [Y/n] 
      Get:1 http://cr.archive.ubuntu.com/ubuntu resolute/universe amd64 libccid amd64 1.7.1-1 [87.7 kB]
      Get:2 http://cr.archive.ubuntu.com/ubuntu resolute/universe amd64 pcscd amd64 2.4.1-1 [59.1 kB]
      Get:3 https://tavocg.github.io/fdcr/noble noble/main amd64 bccr-gaudi amd64 29.0-1 [70.4 MB]
      Fetched 70.6 MB in 2s (31.6 MB/s)     
      Selecting previously unselected package libccid.
      (Reading database… 193531 files and directories currently installed.)
      Preparing to unpack …/libccid_1.7.1-1_amd64.deb…
      Unpacking libccid (1.7.1-1)…
      Selecting previously unselected package pcscd.
      Preparing to unpack …/pcscd_2.4.1-1_amd64.deb…
      Unpacking pcscd (2.4.1-1)…
      Selecting previously unselected package bccr-gaudi.
      Preparing to unpack …/bccr-gaudi_29.0-1_amd64.deb…
      Unpacking bccr-gaudi (29.0-1)…
      Setting up libccid (1.7.1-1)…
      A dependency job for pcscd.service failed. See 'journalctl -xe' for details.
      invoke-rc.d: initscript pcscd, action "restart" failed.
      ○ pcscd.service - PC/SC Smart Card Daemon
          Loaded: loaded (/usr/lib/systemd/system/pcscd.service; indirect; preset: en
      abled)
          Active: inactive (dead)
      TriggeredBy: × pcscd.socket
            Docs: man:pcscd(8)

      Oct 09 16:36:44 ubuntu26 systemd[1]: Dependency failed for pcscd.service - PC/SC
      Smart Card Daemon.
      Oct 09 16:36:44 ubuntu26 systemd[1]: pcscd.service: Job pcscd.service/start fail
      ed with result 'dependency'.
      Setting up pcscd (2.4.1-1)…
      Creating group 'pcscd' with GID 973.
      Creating user 'pcscd' (PC/SC Smart Card Daemon) with UID 973 and GID 973.
      Created symlink '/etc/systemd/system/sockets.target.wants/pcscd.socket' → '/usr/
      lib/systemd/system/pcscd.socket'.
      pcscd.service is a disabled or a static unit, not starting it.
      Setting up bccr-gaudi (29.0-1)…
      Processing triggers for gnome-menus (3.38.1-1ubuntu1)…
      Processing triggers for man-db (2.13.1-1build1)…
      Processing triggers for desktop-file-utils (0.28-1build1)…
      ```

Referencias: [descubrimiento de directorios de jpackage](https://github.com/openjdk/jdk17u/blob/master/src/jdk.jpackage/linux/native/libapplauncher/Package.cpp) y [especificación de lanzadores de escritorio](https://specifications.freedesktop.org/desktop-entry/latest-single/).

## `bccr-certs`

Certificados de la jerarquía nacional de Firma Digital de Costa Rica.

| Distro       | Canal    | Probado |
|--------------|----------|---------|
| Ubuntu 26.04 |          |         |
| Ubuntu 24.04 |          |         |
| Ubuntu 22.04 |          |         |
| Debian 13    |          |         |
| Fedora 45    |          |         |
| Fedora 44    |          |         |
| Fedora 43    |          |         |
| Arch Linux   |          |         |

## `libxml2-idopte-compat`

Biblioteca de compatibilidad publicada en el canal `noble` para Idopte.
Reempaqueta la biblioteca amd64 de [Debian 13](https://packages.debian.org/trixie/libxml2),
versión `2.12.7+dfsg+really2.9.14-2.1+deb13u3`, con descarga y SHA-256 fijados en
`artifacts/artifacts.nix`. Incluye los avisos de licencia y changelogs de Debian.

Instala `libxml2.so.2` y su destino en `/usr/lib/SCMiddleware`, donde las bibliotecas
Idopte ya buscan sus dependencias. No reemplaza la biblioteca del sistema ni declara
`Provides: libxml2`, porque su ubicación privada no satisface a otros programas.
Depende de glibc, liblzma y zlib; no necesita ICU. Solo se publica en `noble`:
la compilación requiere glibc 2.38 y no es adecuada para Jammy.

Al actualizarla, renovar la URL y el hash del artifact, la versión/revisión del paquete
y sus dependencias según el DEB de Debian. La copia privada requiere seguimiento de
las actualizaciones de seguridad de Debian.
