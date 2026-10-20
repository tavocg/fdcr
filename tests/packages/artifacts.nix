let
  f = builtins.getFlake (toString ../..);
  pkgs = f.inputs.nixpkgs.legacyPackages.x86_64-linux;
  metarepo = f.inputs.metarepo.lib.forPkgs pkgs;
  names = [
    "opensc"
    "opensc-git"
    "firmador"
    "firmador-git"
    "bccr-certs"
    "bccr-gaudi"
  ];
  publications = builtins.listToAttrs (
    map (name: {
      inherit name;
      value = pkgs.callPackage (../../packages + "/${name}/public.nix") {
        inherit metarepo;
        package = f.legacyPackages.x86_64-linux.${name};
        repository = import ../../repository.nix;
      };
    }) names
  );
in
pkgs.lib.genAttrs [
  "jammy"
  "noble"
  "debian"
  "resolute"
  "fedora"
  "opensuse"
  "arch"
] (channel: pkgs.lib.genAttrs names (name: map toString publications.${name}.channels.${channel}))
