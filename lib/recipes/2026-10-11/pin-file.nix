# metarepo could expose a helper to isolate local binary/auxiliary inputs by
# content. Store-subpaths otherwise depend on the entire flake source hash;
# returning a contextual store string also survives downstream `toString`.
path:
builtins.path {
  inherit path;
  name = builtins.baseNameOf path;
}
