{
  callPackage,
  fetchFromCodeberg,
  metarepo,
  pname ? "firmador",
  snapshots ? callPackage ./snapshots.nix { },
  default ? "v1_9_8",
}:
metarepo.mkSnapshots {
  inherit snapshots default;
  build = callPackage ./build.nix { inherit pname; };
  source = snapshot: fetchFromCodeberg {
    owner = "firmador";
    repo = "firmador";
    inherit (snapshot) rev hash;
  };
}
