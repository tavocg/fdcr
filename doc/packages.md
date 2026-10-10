# Paquetes

## `idopte-p11`

Middleware Idopte para tarjetas inteligentes y firma digital.

| Distro       | Canal    | Probado |
|--------------|----------|---------|
| Ubuntu 26.04 | noble    | ✅      |
| Ubuntu 24.04 | noble    | ✅      |
| Ubuntu 22.04 | jammy    | ✅      |
| Debian 13    | noble    | ✅      |
| Fedora 45    |          |         |
| Fedora 44    | fedora   | ❌      |
| Fedora 43    |          |         |
| Arch Linux   | arch     | ✅      |

## `idopte-scmanager`

Interfaz gráfica e integración de escritorio de Idopte. Depende de `idopte-p11`.

| Distro       | Canal    | Probado |
|--------------|----------|---------|
| Ubuntu 26.04 | noble    | ✅      |
| Ubuntu 24.04 | noble    | ✅      |
| Ubuntu 22.04 | jammy    | ✅      |
| Debian 13    | noble    | ✅      |
| Fedora 45    |          |         |
| Fedora 44    | fedora   | ❌      |
| Fedora 43    |          |         |
| Arch Linux   | arch     | ✅      |

- [ ] Arreglar en fedora: scmanager muestra los certificados como inválidos,

## `firmador`

Firma de documentos con Firmador Libre.

| Distro       | Canal    | Probado |
|--------------|----------|---------|
| Ubuntu 26.04 | noble    | ✅      |
| Ubuntu 24.04 | noble    | ✅      |
| Ubuntu 22.04 | jammy    | ✅      |
| Debian 13    | noble    | ✅      |
| Fedora 45    |          |         |
| Fedora 44    | fedora   | ✅      |
| Fedora 43    |          |         |
| Arch Linux   | arch     | ✅      |

- [ ] Quitar `idopte-p11` como opcional para el firmador.
- [ ] Arreglar en ubuntu 22.04, 24.04 y 26.04 y en fedora: no tiene ícono.

### Variante `firmador-git`

| Distro       | Canal    | Probado |
|--------------|----------|---------|
| Ubuntu 26.04 | noble    | ✅      |
| Ubuntu 24.04 | noble    | ✅      |
| Ubuntu 22.04 | jammy    | ✅      |
| Debian 13    | noble    | ✅      |
| Fedora 45    |          |         |
| Fedora 44    | fedora   | ✅      |
| Fedora 43    |          |         |
| Arch Linux   | arch     | ✅      |

Comparte la receta de construcción y publicación con `firmador`, pero instala
su comando `firmador-git`, JAR y lanzador en rutas separadas para permitir la
coexistencia. El menú muestra «Firmador Libre (Git)».

Cada snapshot fija un commit y su hash de descarga en
`packages/firmador-git/snapshots.nix`. Al actualizarlo, ajustar también la fecha
(del commit), su hash abreviado y, si cambian las dependencias, `mvnHash`.

- [ ] Arreglar en ubuntu 22.04, 24.04 y 26.04 y en fedora: no tiene ícono.

## `bccr-gaudi`

Agente GAUDI del Banco Central de Costa Rica.

| Distro       | Canal    | Probado |
|--------------|----------|---------|
| Ubuntu 26.04 | noble    | ✅      |
| Ubuntu 24.04 | noble    | ✅      |
| Ubuntu 22.04 | jammy    | ✅      |
| Debian 13    | noble    | ✅      |
| Fedora 45    |          |         |
| Fedora 44    | fedora   | ✅      |
| Fedora 43    |          |         |
| Arch Linux   | arch     | ✅      |

- [ ] Confirmar el arranque en Fedora y el ícono en la barra de tareas de Ubuntu 24.04 con el paquete actualizado.
- [ ] Arreglar en ubuntu 24.04 y 26.04: el Agente GAUDI crea una ventana de 0x0
      para clickear en la barra de tareas y aparece un menú, Esta ventana de 0x0
      Le falta el ícono del Agente GAUDI. Una vez se abre una ventana como
      "mi cuenta" sí aparece el ícono, pero como una entrada separada en la
      barra de tareas.
      En ubuntu 22.04, se muestran correctamente los íconos del lanzador y de la
      barra de tareas del Agente GAUDI, no obstante, sigue ocurriendo el
      problema de que la ventana 0x0 tiene un ícono por separado, en este caso
      sí se muestran apropiadamente dos íconos, pero deberían ser una única
      entrada.

Referencias: [descubrimiento de directorios de jpackage](https://github.com/openjdk/jdk17u/blob/master/src/jdk.jpackage/linux/native/libapplauncher/Package.cpp) y [especificación de lanzadores de escritorio](https://specifications.freedesktop.org/desktop-entry/latest-single/).

## `bccr-certs`

Certificados de la jerarquía nacional de Firma Digital de Costa Rica.

| Distro       | Canal    | Probado |
|--------------|----------|---------|
| Ubuntu 26.04 | noble    | ✅      |
| Ubuntu 24.04 | noble    | ✅      |
| Ubuntu 22.04 | jammy    | ✅      |
| Debian 13    | noble    | ✅      |
| Fedora 45    |          |         |
| Fedora 44    | fedora   |         |
| Fedora 43    |          |         |
| Arch Linux   | arch     | ✅      |

## `libxml2-idopte-compat`

| Distro       | Canal    | Probado |
|--------------|----------|---------|
| Ubuntu 26.04 | noble    | ✅      |

Biblioteca de compatibilidad publicada en el canal `noble` para Idopte.
Reempaqueta la biblioteca amd64 de [Debian 13](https://packages.debian.org/trixie/libxml2),
versión `2.12.7+dfsg+really2.9.14-2.1+deb13u3`, con descarga y SHA-256 fijados en
`artifacts/artifacts.nix`. Incluye los avisos de licencia y changelogs de Debian.

Instala `libxml2.so.2` y su destino en `/usr/lib/SCMiddleware`, donde las bibliotecas
Idopte ya buscan sus dependencias. No reemplaza la biblioteca del sistema.

> [!NOTE]
> Al actualizarla, renovar la URL y el hash del artifact, la versión/revisión del paquete
> y sus dependencias según el DEB de Debian. La copia privada requiere seguimiento de
> las actualizaciones de seguridad de Debian.
