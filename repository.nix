{
  id = "fdcr";
  origin = "fdcr";
  label = "Paquetes de firma digital para Costa Rica";
  url = "https://tavocg.github.io/fdcr";
  channels = {
    jammy = {
      format = "apt";
      releases = [ "ubuntu2204" ];
    };
    noble = {
      format = "apt";
      releases = [
        "ubuntu2404"
        "linuxmint223"
      ];
    };
    debian = {
      inherits = "noble";
      format = "apt";
      releases = [
        "debian13"
        "linuxmint7"
      ];
    };
    ubuntu2604 = {
      inherits = "noble";
      format = "apt";
      releases = [ "ubuntu2604" ];
    };
    fedora = {
      format = "dnf";
      releases = [
        "fedora45"
        "fedora44"
        "fedora43"
      ];
    };
    opensuse = {
      inherits = "fedora";
      format = "dnf";
      releases = [
        "opensuse-tumbleweed"
        "opensuse-leap160"
      ];
    };
    arch = {
      format = "pacman";
      releases = [ "arch" ];
    };
  };
}
