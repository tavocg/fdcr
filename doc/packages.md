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

> [!NOTE]
> En Ubuntu 26.04 se observa un fallo durante la instalación de sus componentes
> PC/SC: el socket intenta arrancar antes de crearse el usuario `pcscd`
> (`Failed to resolve user`, `217/USER`). En las pruebas, un segundo después
> `pcscd.socket` ya estaba escuchando y completamente funcional sin requerir
> intervención manual.
>
> Observado el 2026-10-10.

### Servicio `idocachesrv` (Fedora 44)

El 2026-10-10 se comprobó que `/etc/idoss.lic` y `/etc/idoss.conf` estaban
instalados y que `rpm -V idopte-p11` no detectaba alteraciones. Con la unidad
actual (`Type=simple`), `idocachesrv` terminaba inmediatamente con
`status=0/SUCCESS` y systemd desactivaba el servicio.

El ejecutable se separa del proceso inicial y el script del proveedor usa
`/var/run/idoCacheSrv.pid`. Se probó este ajuste local:

```ini
# /etc/systemd/system/idocachesrv.service.d/90-fdcr-forking.conf
[Service]
Type=forking
PIDFile=/run/idoCacheSrv.pid
```

Después de recargar systemd y reiniciar el servicio, permaneció `active (running)`
y su PID coincidió con el archivo. Este ajuste **no resolvió** el rechazo de
certificados de SCManager; era un problema independiente.

Por decisión del mantenedor, el ajuste queda documentado y **no se aplica a la
unidad del repositorio**, que conserva `Type=simple`.

## `idopte-scmanager`

Interfaz gráfica e integración de escritorio de Idopte. Depende de `idopte-p11`.

| Distro       | Canal    | Probado |
|--------------|----------|---------|
| Ubuntu 26.04 | noble    | ✅      |
| Ubuntu 24.04 | noble    | ✅      |
| Ubuntu 22.04 | jammy    | ✅      |
| Debian 13    | noble    | ✅      |
| Fedora 45    |          |         |
| Fedora 44    | fedora   | ✅¹     |
| Fedora 43    |          |         |
| Arch Linux   | arch     | ✅      |

¹ Con `ca-certificates` actualizado, como se detalla a continuación.

### Certificados marcados como inválidos en Fedora 44

Resuelto en la prueba del 2026-10-10 actualizando el almacén del sistema:

```sh
sudo dnf upgrade --refresh ca-certificates
sudo update-ca-trust extract
```

SCManager del artifact Noble contiene en su binario la ruta
`/etc/ssl/certs/ca-certificates.crt`. La VM tenía
`ca-certificates-2025.2.80_v9.0.304-6.fc44`, donde esa ruta no existía, aunque sí
existía `/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem`.

Crear un enlace entre ambas rutas resolvió el problema; posteriormente se confirmó
que actualizar `ca-certificates` también lo resolvía. Fedora restauró la estructura
de compatibilidad en la revisión `2025.2.80_v9.0.304-7`, según su
[changelog](https://packages.fedoraproject.org/pkgs/ca-certificates/ca-certificates/fedora-44-updates.html).
Se recomienda actualizar el paquete en lugar de crear el enlace manualmente.

El RPM de SCManager declara `ca-certificates` como dependencia sin versión mínima.
Esto asegura su instalación, pero una versión antigua ya instalada también satisface
la dependencia. En ese caso sigue siendo necesario actualizarla con el comando anterior;
`dnf install --refresh` actualiza los metadatos, no garantiza actualizar esa dependencia.

No fue necesario instalar `bccr-certs`, parchear el binario ni cambiar al artifact
RPM. Este último también contiene una ruta que faltaba en esa VM:
`/etc/pki/tls/certs/ca-bundle.crt`. Se conserva el artifact Noble.

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

Referencias: [descubrimiento de directorios de jpackage](https://github.com/openjdk/jdk17u/blob/master/src/jdk.jpackage/linux/native/libapplauncher/Package.cpp) y [especificación de lanzadores de escritorio](https://specifications.freedesktop.org/desktop-entry/latest-single/).

## `bccr-certs`

Certificados de la jerarquía nacional de Firma Digital de Costa Rica.

En Fedora, el RPM ejecuta `update-ca-trust extract` al finalizar la transacción de
instalación o actualización (`%posttrans`) y después de la desinstalación definitiva
(`%postun`, si la herramienta sigue instalada). La dependencia `ca-certificates`
se mantiene sin versión mínima. Estos scripts regeneran el almacén, sin ejecutar DNF
ni actualizar paquetes. La adaptación del spec está limitada a `bccr-certs` mientras
metarepo no exponga argumentos para scripts RPM.

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
