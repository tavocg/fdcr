{ lib, metarepo, repository, package }:
let
  snapshots = builtins.attrValues (package.passthru.snapshots or { current = package; });
  settings = pkg: pkg.passthru.repository or { };
  publish = channel:
    let
      packages = builtins.filter (pkg: builtins.elem channel
        ((settings pkg).channels or (builtins.attrNames repository.channels))) snapshots;
      versions = map (pkg: "${pkg.version}-${(settings pkg).release or "1"}") packages;
      build = pkg:
        let
          config = settings pkg;
          publication = metarepo.mkPublication ({
            inherit repository;
            package = pkg;
            payload = pkg;
          } // (config.configure or (_: _: { })) pkg channel
            // builtins.removeAttrs config [ "configure" "transform" ] // {
              channels = [ channel ];
            });
          transform = (config.transform or (_: archive: archive)) repository.channels.${channel}.format;
        in map transform publication.channels.${channel};
    in assert lib.assertMsg (builtins.length versions == builtins.length (lib.unique versions))
      "${package.pname}: snapshots must have distinct version-release pairs in ${channel}";
      lib.concatMap build packages;
in {
  channels = lib.genAttrs (builtins.attrNames repository.channels) publish;
}
