{
  fetchFromCodeberg,
  rev,
  hash,
}:
fetchFromCodeberg {
  owner = "firmador";
  repo = "firmador";
  inherit rev hash;
}
