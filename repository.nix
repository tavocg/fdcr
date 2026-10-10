{
  id = "fdcr";
  origin = "fdcr";
  label = "Paquetes de firma digital para Costa Rica";
  url = "https://tavocg.github.io/fdcr";
  channels = {
    jammy = { format = "apt"; releases = [ "ubuntu2204" ]; };
    noble = { format = "apt"; releases = [ "ubuntu2404" "debian13" ]; };
    fedora = { format = "dnf"; releases = [ "fedora45" "fedora44" "fedora43" ]; };
    arch = { format = "pacman"; releases = [ "arch" ]; };
  };
}
