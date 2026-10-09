{
  lib,
  stdenv,
  dpkg,
  unzip,
  patchelf,
}:
import ../idopte-p11/package.nix {
  inherit lib stdenv dpkg unzip patchelf;
  sourceZip = ../idopte-p11/artifacts/sfd_ClientesLinux_DEB64_Ubuntu22_rev26_08.zip;
  sourceMd5 = "348e3c06ef5218542266bdf417c13e36";
  debPath = "sfd_ClientesLinux_DEB64_Ubuntu22_26_08/Firma Digital/Idopte/Idopte_6.23.50.5_ubun22_amd64.deb";
}
