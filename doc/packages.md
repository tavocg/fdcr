# Paquetes

## `idopte-p11`

Middleware Idopte para tarjetas inteligentes y firma digital.

| Distro       | Canal    | Probado |
|--------------|----------|---------|
| Ubuntu 26.04 |          |         |
| Ubuntu 24.04 | noble    | ✅      |
| Ubuntu 22.04 | jammy    | ✅      |
| Debian 13    | noble    | ✅      |
| Debian 12    | noble?   |         |
| Fedora 45    | fedora   |         |
| Fedora 44    | fedora   |         |
| Fedora 43    | fedora   |         |
| Arch Linux   | arch     | ✅      |

Notas:

- [x] Arch: agregado un hook de pacman que inicia `pcscd.socket` después de instalar o actualizar `idopte-p11`, cuando systemd está activo. El socket activa `pcscd` cuando una aplicación lo necesita.
- [ ] Confirmar la activación inmediata en una instalación nueva de Arch, sin reiniciar.

## `idopte-scmanager`

Interfaz gráfica e integración de escritorio de Idopte. Depende de `idopte-p11`.

| Distro       | Canal    | Probado |
|--------------|----------|---------|
| Ubuntu 26.04 |          |         |
| Ubuntu 24.04 | noble    | ✅      |
| Ubuntu 22.04 | jammy    | ✅      |
| Debian 13    | noble    | ✅      |
| Debian 12    | noble?   |         |
| Fedora 45    | fedora   |         |
| Fedora 44    | fedora   |         |
| Fedora 43    | fedora   |         |
| Arch Linux   | arch     | ✅      |

Notas:

- [x] Agregado `StartupWMClass=SCManager` al lanzador y al inicio automático para asociar las ventanas con su ícono.
- [ ] Confirmar el ícono en la barra de tareas de Ubuntu 24.04 con el paquete actualizado.

## `firmador`

Firma de documentos con Firmador Libre.

| Distro       | Canal    | Probado |
|--------------|----------|---------|
| Ubuntu 26.04 |          |         |
| Ubuntu 24.04 | noble    | ✅      |
| Ubuntu 22.04 | jammy    | ✅      |
| Debian 13    | noble    | ✅      |
| Debian 12    | noble?   |         |
| Fedora 45    | fedora   |         |
| Fedora 44    | fedora   |         |
| Fedora 43    | fedora   |         |
| Arch Linux   | arch     | ✅      |

Notas:

- [x] Agregado `StartupWMClass=Firmador` al lanzador para asociar las ventanas de Java con su ícono.
- [ ] Confirmar el ícono en la barra de tareas de Ubuntu 24.04 con el paquete actualizado.

## `bccr-gaudi`

Agente GAUDI del Banco Central de Costa Rica.

| Distro       | Canal    | Probado |
|--------------|----------|---------|
| Ubuntu 26.04 |          |         |
| Ubuntu 24.04 | noble    | ✅      |
| Ubuntu 22.04 | jammy    | ✅      |
| Debian 13    | noble    | ✅      |
| Debian 12    | noble?   |         |
| Fedora 45    | fedora   |         |
| Fedora 44    | fedora   |         |
| Fedora 43    | fedora   |         |
| Arch Linux   | arch     | ✅      |

Notas:

- [x] Fedora: registrados explícitamente `/opt/Agente-GAUDI/lib/app` y `/opt/Agente-GAUDI/lib/runtime` en el RPM. El lanzador de jpackage busca esos directorios en `rpm -ql`; su ausencia causaba los errores al localizar `Agente-GAUDI.cfg` y la JVM integrada. No requiere instalar otro Java ni cambiar el directorio de trabajo.
- [x] Agregado `StartupWMClass=bccr.principal.InicializadorDeActualizacion` al lanzador y al inicio automático para asociar las ventanas de JavaFX con su ícono. Eliminado el campo opcional `Version`, que identifica la versión del formato `.desktop`, no la de GAUDI.
- [ ] Confirmar el arranque en Fedora y el ícono en la barra de tareas de Ubuntu 24.04 con el paquete actualizado.

Referencias: [descubrimiento de directorios de jpackage](https://github.com/openjdk/jdk17u/blob/master/src/jdk.jpackage/linux/native/libapplauncher/Package.cpp) y [especificación de lanzadores de escritorio](https://specifications.freedesktop.org/desktop-entry/latest-single/).

## `bccr-certs`

Certificados de la jerarquía nacional de Firma Digital de Costa Rica.

| Distro       | Canal    | Probado |
|--------------|----------|---------|
| Ubuntu 26.04 |          |         |
| Ubuntu 24.04 | noble    | ✅      |
| Ubuntu 22.04 | jammy    | ✅      |
| Debian 13    | noble    | ✅      |
| Debian 12    | noble?   |         |
| Fedora 45    | fedora   |         |
| Fedora 44    | fedora   |         |
| Fedora 43    | fedora   |         |
| Arch Linux   | arch     | ✅      |
