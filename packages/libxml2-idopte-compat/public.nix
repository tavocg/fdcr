{ metarepo, package }:
{
  channels.noble = metarepo.mkApt {
    payload = package;
    name = package.pname;
    version = package.version;
    # Preserve the Debian security revision of the repackaged library.
    release = "2.1+deb13u3";
    architecture = "amd64";
    maintainer = "FDCR package maintainers";
    inherit (package.meta) description homepage;
    license = "MIT";
    depends = [
      "libc6 (>= 2.38)"
      "liblzma5 (>= 5.1.1alpha+20120614)"
      "zlib1g (>= 1:1.2.3.4)"
    ];
  };
}
