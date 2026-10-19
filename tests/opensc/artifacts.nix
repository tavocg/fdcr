let
  f = builtins.getFlake (toString ../..);
  pkgs = f.inputs.nixpkgs.legacyPackages.${builtins.currentSystem};
  m = f.inputs.metarepo.lib.forPkgs pkgs;
  build =
    name:
    let
      p = pkgs.callPackage (../../packages + "/${name}/package.nix") { metarepo = m; };
      pub = pkgs.callPackage (../../packages + "/${name}/public.nix") {
        package = p;
        repository = import ../../repository.nix;
      };
    in
    pkgs.lib.unique (pkgs.lib.concatLists (builtins.attrValues pub.channels));
in
build "opensc" ++ build "opensc-git"
