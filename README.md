# fdcr (ALPHA)

> [!WARNING]
> No usar en producción todavía, actualmente este repositorio se encuentra en
> fase de pruebas.

Repositorio de dependencias para Firma Digital en Costa Rica.

- `firmador`
- `firmador-git`
- `opensc`
- `opensc-git`
- `bccr-gaudi`
- `bccr-certs`
- `idopte-p11`
- `idopte-scmanager`

## Instalación

```sh
curl -fsSL https://tavocg.github.io/fdcr/install.sh | sudo sh
```

Para instalación manual, véase [doc/install.md](doc/install.md).

## Uso

```sh
# Debian/Ubuntu
sudo apt install firmador opensc

# Fedora
sudo dnf install firmador ccid
sudo dnf install --repo=fdcr opensc --allowerasing

# Arch
sudo pacman -S firmador fdcr/opensc ccid
sudo systemctl enable --now pcscd.{socket,service}
```

También publica un módulo NixOS (`nixosModules.default`) que adapta el middleware
y SCManager; véase [doc/nixos.md](doc/nixos.md).

Para usar SCManager y Firmador desde un perfil o devShell, véase
[uso con Nix](doc/nix.md). Ambos incluyen el middleware Idopte.

Consulta el [estado de la paquetería](doc/packages.md) y las
[recetas de OpenSC](packages/opensc/README.md).

## Desarrollo

Las fuentes, herramientas y recetas de construcción/publicación están fijadas
por snapshot. Todos los paquetes tienen `snapshots.nix`; los builders y las
extracciones de artifacts se versionan sin modificar las recetas anteriores.
Consulta [cómo agregar versiones y builders](doc/snapshots.md).

```sh
nix flake show
nix flake check
nix run .#build-public
```

Se genera la raíz del repositorio en `public/`. Para firmar los paquetes con
`gpg`, asigna `GPG_KEY_ID`.
