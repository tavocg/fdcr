# Instalación manual del repositorio

El script generado `public/install.sh` configura el repositorio automáticamente
para las versiones y arquitecturas compatibles de cada distribución. Los
ejemplos siguientes configuran manualmente el repositorio alojado en
`https://tavocg.github.io/fdcr`.

## Ubuntu (`apt`)

```sh
BASE_URL=https://tavocg.github.io/fdcr
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL "$BASE_URL/fdcr.asc" | sudo gpg --dearmor --yes -o /etc/apt/keyrings/fdcr.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/fdcr.gpg] $BASE_URL/noble noble main" \
  | sudo tee /etc/apt/sources.list.d/fdcr.list >/dev/null
sudo apt update
```

```sh
sudo apt install firmador
```

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
[fdcr-arch]
SigLevel = Required
Server = https://tavocg.github.io/fdcr/arch/
```

```sh
sudo pacman -Sy firmador
```

## Nix

El flake también ofrece Firmador directamente.

```sh
nix profile install github:tavocg/fdcr#firmador
nix run github:tavocg/fdcr#firmador
```
