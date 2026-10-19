# Paquetes

## `idopte-p11`

Middleware Idopte para tarjetas inteligentes y firma digital.

| Distro       | Canal    | Probado |
|--------------|----------|---------|
| Ubuntu 26.04 | ubuntu2604    | ✅      |
| Ubuntu 24.04 | noble    | ✅      |
| Ubuntu 22.04 | jammy    | ✅      |
| Debian 13    | debian    | ✅      |
| Fedora 45    |          |         |
| Fedora 44    | fedora   | ✅      |
| Fedora 43    |          |         |
| Arch Linux   | arch     | ✅      |

> [!NOTE]
> En Ubuntu 26.04 se observa un fallo durante la instalación de sus componentes
> PC/SC: el socket intenta arrancar antes de crearse el usuario `pcscd`
> (`Failed to resolve user`, `217/USER`). En las pruebas, un segundo después
> `pcscd.socket` ya estaba escuchando y completamente funcional sin requerir
> intervención manual.
>
> Observado el 2026-10-10.

- [ ] Comprobar `idocachesrv`, ¿necesita quedarse corriendo? Considerar `Type=forking`.

## `idopte-scmanager`

Interfaz gráfica e integración de escritorio de Idopte. Depende de `idopte-p11`.

| Distro       | Canal    | Probado |
|--------------|----------|---------|
| Ubuntu 26.04 | ubuntu2604    | ✅      |
| Ubuntu 24.04 | noble    | ✅      |
| Ubuntu 22.04 | jammy    | ✅      |
| Debian 13    | debian    | ✅      |
| Fedora 45    |          |         |
| Fedora 44    | fedora   | ✅      |
| Fedora 43    |          |         |
| Arch Linux   | arch     | ✅      |

## `firmador`

Firma de documentos con Firmador Libre.

| Distro       | Canal    | Probado |
|--------------|----------|---------|
| Ubuntu 26.04 | ubuntu2604    | ✅      |
| Ubuntu 24.04 | noble    | ✅      |
| Ubuntu 22.04 | jammy    | ✅      |
| Debian 13    | debian    | ✅      |
| Fedora 45    |          |         |
| Fedora 44    | fedora   | ✅      |
| Fedora 43    |          |         |
| Arch Linux   | arch     | ✅      |

### Variante `firmador-git`

Selecciona el mismo builder Java versionado de construcción y publicación que
`firmador`, pero instala su comando `firmador-git`, en rutas separadas para permitir la
coexistencia.

Cada snapshot fija commit, hash, herramientas y dependencias en su propio
directorio. `packages/firmador-git/snapshots.nix` registra esas recetas;
[doc/snapshots.md](snapshots.md) explica cómo agregar una sin cambiar las anteriores.

| Distro       | Canal    | Probado |
|--------------|----------|---------|
| Ubuntu 26.04 | ubuntu2604    | ✅      |
| Ubuntu 24.04 | noble    | ✅      |
| Ubuntu 22.04 | jammy    | ✅      |
| Debian 13    | debian    | ✅      |
| Fedora 45    |          |         |
| Fedora 44    | fedora   | ✅      |
| Fedora 43    |          |         |
| Arch Linux   | arch     | ✅      |

## `bccr-gaudi`

Agente GAUDI del Banco Central de Costa Rica.

| Distro       | Canal    | Probado |
|--------------|----------|---------|
| Ubuntu 26.04 | ubuntu2604    | ✅      |
| Ubuntu 24.04 | noble    | ✅      |
| Ubuntu 22.04 | jammy    | ✅      |
| Debian 13    | debian    | ✅      |
| Fedora 45    |          |         |
| Fedora 44    | fedora   | ✅      |
| Fedora 43    |          |         |
| Arch Linux   | arch     | ✅      |

## `bccr-certs`

Certificados de la jerarquía nacional de Firma Digital de Costa Rica.

| Distro       | Canal    | Probado |
|--------------|----------|---------|
| Ubuntu 26.04 | ubuntu2604    | ✅      |
| Ubuntu 24.04 | noble    | ✅      |
| Ubuntu 22.04 | jammy    | ✅      |
| Debian 13    | debian    | ✅      |
| Fedora 45    |          |         |
| Fedora 44    | fedora   | ✅      |
| Fedora 43    |          |         |
| Arch Linux   | arch     | ✅      |

## `libxml2-idopte-compat`

| Distro       | Canal    | Probado |
|--------------|----------|---------|
| Ubuntu 26.04 | ubuntu2604    | ✅      |

Biblioteca de compatibilidad publicada en los canales `noble`, `ubuntu2604` y `debian` para Idopte.
Reempaqueta la biblioteca amd64 de [Debian 13](https://packages.debian.org/trixie/libxml2),
versión `2.12.7+dfsg+really2.9.14-2.1+deb13u3`, con descarga y SHA-256 fijados en
`artifacts/recipes/2026-10-11/libxml2.nix`. Incluye los avisos de licencia y
changelogs de Debian.

Instala `libxml2.so.2` y su destino en `/usr/lib/SCMiddleware`, donde las bibliotecas
Idopte ya buscan sus dependencias. No reemplaza la biblioteca del sistema.

> [!NOTE]
> Al actualizarla, agregar una receta y snapshot nuevas con URL, hash, versión/revisión
> y dependencias según el DEB de Debian, conservando las recetas anteriores.
> La copia privada requiere seguimiento de las actualizaciones de seguridad de Debian.
