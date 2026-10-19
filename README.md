# fdcr

Repositorio de dependencias para Firma Digital en Costa Rica.

> [!NOTE]
> Fase beta del repositorio, podrían haber cambios que rompan compatibilidad.

- Firmador Libre: `firmador`, `firmador-git`
- OpenSC parcheado para funcionar con JCOP3/4 del BCCR: `opensc`, `opensc-git`
- Agente GAUDI y certificados del BCCR: `bccr-gaudi`, `bccr-certs`
  (construcción suspendida hasta reincorporar los artifacts).

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
sudo dnf install ccid firmador
sudo dnf upgrade --from-repo=fdcr opensc --best --allowerasing

# Arch
sudo pacman -S ccid firmador fdcr/opensc
sudo systemctl enable --now pcscd.{socket,service}
```

[Uso con Nix](doc/nix.md).

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
