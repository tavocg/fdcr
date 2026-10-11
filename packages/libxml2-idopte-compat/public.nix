{ metarepo, repository, package }:
metarepo.mkPublication {
  inherit repository package;
  payload = package;
  channels = [ "noble" ];
  # Preserve the Debian security revision of the repackaged library.
  release = "2.1+deb13u3";
  maintainer = "FDCR package maintainers";
  depends = [
    "libc6 (>= 2.38)"
    "liblzma5 (>= 5.1.1alpha+20120614)"
    "zlib1g (>= 1:1.2.3.4)"
  ];
}
