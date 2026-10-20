# Paquetes

## `opensc`

| Distro       | Canal      | Probado |
|--------------|------------|---------|
| Ubuntu 26.04 | resolute | ✅      |
| Ubuntu 24.04 | noble      | ✅      |
| Ubuntu 22.04 | jammy      | ✅      |
| Debian 13    | debian     | ✅      |
| Fedora 45    |            |         |
| Fedora 44    | fedora     | ✅      |
| Fedora 43    |            |         |
| Arch Linux   | arch       | ✅      |

OpenSC con soporte para las tarjetas de Firma Digital del Banco Central de Costa
Rica (BCCR). La variante estable fija el commit de una versión publicada de OpenSC.
Los parches de soporte BCCR son realizados por Francisco de la Peña
<fran@fran.cr>.

### Variante `opensc-git`

| Distro       | Canal      | Probado |
|--------------|------------|---------|
| Ubuntu 26.04 | resolute |         |
| Ubuntu 24.04 | noble      |         |
| Ubuntu 22.04 | jammy      |         |
| Debian 13    | debian     |         |
| Fedora 45    |            |         |
| Fedora 44    | fedora     |         |
| Fedora 43    |            |         |
| Arch Linux   | arch       |         |

Incluye los mismos parches de Francisco de la Peña <fran@fran.cr>, sobre un commit
fijado de la rama `master` de OpenSC.
Las dos variantes son alternativas: reemplazan OpenSC de la distribución y sus
bibliotecas separadas.

Consulta los [detalles de empaquetado](../packages/opensc/README.md) y la
[las pruebas de instalación](../tests/opensc/README.md).

## `firmador`

Firma de documentos con Firmador Libre.

| Distro       | Canal      | Probado |
|--------------|------------|---------|
| Ubuntu 26.04 | resolute | ✅      |
| Ubuntu 24.04 | noble      | ✅      |
| Ubuntu 22.04 | jammy      | ✅      |
| Debian 13    | debian     | ✅      |
| Fedora 45    |            |         |
| Fedora 44    | fedora     | ✅      |
| Fedora 43    |            |         |
| Arch Linux   | arch       | ✅      |

### Variante `firmador-git`

Selecciona el mismo builder Java versionado de construcción y publicación que
`firmador`, pero instala su comando `firmador-git`, en rutas separadas para permitir la
coexistencia.

Cada snapshot fija commit, hash, herramientas y dependencias en su propio
directorio. `packages/firmador-git/snapshots.nix` registra esas recetas;
[doc/snapshots.md](snapshots.md) explica cómo agregar una sin cambiar las anteriores.

| Distro       | Canal      | Probado |
|--------------|------------|---------|
| Ubuntu 26.04 | resolute | ✅      |
| Ubuntu 24.04 | noble      | ✅      |
| Ubuntu 22.04 | jammy      | ✅      |
| Debian 13    | debian     | ✅      |
| Fedora 45    |            |         |
| Fedora 44    | fedora     | ✅      |
| Fedora 43    |            |         |
| Arch Linux   | arch       | ✅      |

## `bccr-gaudi`

Artifacts registrados en `artifacts/bccr/2026-10-20/` (Git LFS).

Agente GAUDI del Banco Central de Costa Rica.

| Distro       | Canal      | Probado |
|--------------|------------|---------|
| Ubuntu 26.04 | resolute | ✅      |
| Ubuntu 24.04 | noble      | ✅      |
| Ubuntu 22.04 | jammy      | ✅      |
| Debian 13    | debian     | ✅      |
| Fedora 45    |            |         |
| Fedora 44    | fedora     | ✅      |
| Fedora 43    |            |         |
| Arch Linux   | arch       | ✅      |

## `bccr-certs`

Artifacts registrados en `artifacts/bccr-certs-26.08/` (Git LFS).

Certificados de la jerarquía nacional de Firma Digital de Costa Rica.

| Distro       | Canal      | Probado |
|--------------|------------|---------|
| Ubuntu 26.04 | resolute | ✅      |
| Ubuntu 24.04 | noble      | ✅      |
| Ubuntu 22.04 | jammy      | ✅      |
| Debian 13    | debian     | ✅      |
| Fedora 45    |            |         |
| Fedora 44    | fedora     | ✅      |
| Fedora 43    |            |         |
| Arch Linux   | arch       | ✅      |

## Windows

`firmador`, `firmador-git`, `opensc` y `opensc-git` generan MSI para Windows 11
x64. Consulta [instalación y construcción](windows.md). Las pruebas Linux de las
tablas anteriores no certifican funcionamiento en Windows.
