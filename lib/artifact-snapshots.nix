{ lib }:
# Adapt prepared artifact components; snapshots can also supply any derivation directly.
{ revision, artifact, component, build }:
lib.mapAttrs' (variant: components:
  let source = components.${component};
  in lib.nameValuePair "${revision}-${variant}" {
    package = build (builtins.removeAttrs source [ "publication" ]);
    publication = source.publication or { };
  }
) (lib.filterAttrs (_: components: components ? ${component}) artifact)
