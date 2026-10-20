let
  f = builtins.getFlake (toString ../..);
  pkgs = f.inputs.nixpkgs.legacyPackages.x86_64-linux;
  m = f.inputs.metarepo.lib.forPkgs pkgs;
  packages = f.legacyPackages.x86_64-linux;
  names = [ "firmador" "firmador-git" "opensc" "opensc-git" "bccr-certs" "bccr-gaudi" ];
  publish = name: pkgs.callPackage (../../packages + "/${name}/public.nix") {
    package = packages.${name};
    repository = import ../../repository.nix;
    metarepo = m;
  };
in
pkgs.lib.unique ((map (name: packages.${name}) names) ++ pkgs.lib.concatMap (name: pkgs.lib.concatLists (builtins.attrValues (publish name).channels)) names)
