# Keep builder identifiers shared with the stable package; snapshots fix pname.
{ callPackage }: import ../firmador/builders.nix { inherit callPackage; }
