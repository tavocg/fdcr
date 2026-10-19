{
  fetchurl,
  rev,
  hash,
}:
fetchurl {
  name = "opensc-${rev}.tar.gz";
  url = "https://codeload.github.com/OpenSC/OpenSC/tar.gz/${rev}";
  sha256 = hash;
}
