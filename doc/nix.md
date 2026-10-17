# Perfil y devShell de Nix

En `x86_64-linux`, los paquetes `idopte-scmanager`, `firmador` y `firmador-git`
incluyen el middleware `idopte-p11` adaptado a Nix. Cada aplicación se ejecuta en
un entorno FHS que proporciona `/usr/lib/SCMiddleware`, `/etc/idoss.conf` y
`/etc/idoss.lic`, sin instalar esos archivos en el host. Firmador recibe
`LIBASEP11` apuntando al middleware incluido.

Desde este repositorio:

```sh
nix profile install .#idopte-scmanager .#firmador
SCManager
firmador
```

O temporalmente:

```sh
nix develop .#scmanager --command SCManager
nix develop .#firmador --command firmador
nix develop .#firmador-git --command firmador-git
```

`nix develop` incluye SCManager y Firmador. También puedes usar
`nix run .#idopte-scmanager` o `nix run .#firmador`.

El host debe proporcionar una sesión gráfica, permitir los espacios de nombres
que usa Bubblewrap y tener `pcscd` funcionando con acceso al lector. En NixOS:

```nix
services.pcscd.enable = true;
```

El perfil y las devShells no instalan servicios, certificados en el almacén del
sistema ni la extensión de Nautilus. Para integrar esos componentes, consulta
[el módulo NixOS](nixos.md).

Los payloads originales, sus snapshots y publicaciones se conservan en
`legacyPackages.<system>`. Los paquetes de otras arquitecturas conservan el
comportamiento anterior; el middleware Idopte solo está disponible para x86_64.
