# Instalación manual del repositorio

El script generado `public/install.sh` configura el repositorio automáticamente
para las versiones y arquitecturas compatibles de cada distribución. Los
ejemplos siguientes configuran manualmente el repositorio alojado en
`https://tavocg.github.io/fdcr`.

## Ubuntu y Debian (`apt`)

```sh
BASE_URL=https://tavocg.github.io/fdcr
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL "$BASE_URL/fdcr.asc" | sudo gpg --dearmor --yes -o /etc/apt/keyrings/fdcr.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/fdcr.gpg] $BASE_URL/apt noble main" \
  | sudo tee /etc/apt/sources.list.d/fdcr.list >/dev/null
sudo apt update
```

```sh
sudo apt install firmador
```

El middleware Idopte se instala por separado. Para instalarlo junto con su
administrador gráfico de tarjetas:

```sh
sudo apt install idopte-p11 idopte-scmanager
```

Para Ubuntu 22.04 usa `jammy`; para Ubuntu 24.04, `noble`; para Ubuntu 26.04,
`ubuntu2604`; para Debian 13, `debian`. Sustituye la suite `noble` en el ejemplo según corresponda; la URL termina
siempre en `/apt`.

Si configuraste el repositorio antes del pool compartido, vuelve a ejecutar el
instalador o cambia la URL anterior (`/noble`, `/jammy`, `/debian` o
`/ubuntu2604`) por `/apt` en la entrada APT, conservando la suite. Después
ejecuta `sudo apt update`.

## Fedora (`dnf`)

Crea el archivo `/etc/yum.repos.d/fdcr.repo`:

```ini
[fdcr]
name=Paquetes de firma digital para Costa Rica
baseurl=https://tavocg.github.io/fdcr/fedora/
enabled=1
gpgcheck=1
# Deshabilita la verificación de firmas de los metadatos para evitar la advertencia correspondiente.
repo_gpgcheck=0
gpgkey=https://tavocg.github.io/fdcr/fdcr.asc
```

```sh
sudo dnf install firmador
```

El middleware y su administrador gráfico se instalan por separado:

```sh
sudo dnf install idopte-p11 idopte-scmanager
```

## openSUSE Leap 16.0 y Tumbleweed (`zypper`)

openSUSE usa el canal RPM `opensuse`. El instalador automático detecta
Zypper y configura `/etc/zypp/repos.d/fdcr.repo` con el alias `fdcr`.
Para configurarlo manualmente, crea ese archivo:

```ini
[fdcr]
name=Paquetes de firma digital para Costa Rica
baseurl=https://tavocg.github.io/fdcr/opensuse/
enabled=1
autorefresh=1
gpgcheck=1
pkg_gpgcheck=1
repo_gpgcheck=0
gpgkey=https://tavocg.github.io/fdcr/fdcr.asc
```

```sh
sudo rpm --import https://tavocg.github.io/fdcr/fdcr.asc
sudo zypper refresh fdcr
sudo zypper install firmador
sudo zypper install idopte-p11 idopte-scmanager
```

## Arch Linux (`pacman`)

```sh
tmp="$(mktemp)"
curl -fsSLo "$tmp" https://tavocg.github.io/fdcr/fdcr.asc
gpg --show-keys --with-fingerprint "$tmp"
fingerprint="$(gpg --show-keys --with-colons "$tmp" |
  sed -n '/^fpr:/ { s/:$//; s/.*://; p; q; }')"
sudo pacman-key --add "$tmp"
sudo pacman-key --lsign-key "$fingerprint"
rm -f "$tmp"
```

Agrega el repositorio a `/etc/pacman.conf`:

```ini
[fdcr]
SigLevel = Required
Server = https://tavocg.github.io/fdcr/arch/
```

```sh
sudo pacman -Sy firmador
```

El middleware y su administrador gráfico se instalan por separado:

```sh
sudo pacman -S idopte-p11 idopte-scmanager
```

## Nix

El flake también ofrece Firmador directamente.

```sh
nix profile install github:tavocg/fdcr#firmador
nix run github:tavocg/fdcr#firmador
```

## NixOS

El flake publica un módulo NixOS que adapta el middleware y SCManager a las
rutas de NixOS (solo `x86_64-linux`):

```nix
{
  inputs.fdcr.url = "github:tavocg/fdcr";

  outputs = { self, nixpkgs, fdcr, ... }: {
    nixosConfigurations.mi-equipo = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        fdcr.nixosModules.default
        { services.fdcr.enable = true; }
      ];
    };
  };
}
```

Para el detalle de las opciones, Firmador con su biblioteca PKCS#11,
certificados y un ejemplo completo, véase [doc/nixos.md](nixos.md).
