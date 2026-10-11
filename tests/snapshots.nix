{
  pkgs,
  metarepo,
  packages,
  repository,
}:
let
  inherit (pkgs) lib;
  expected =
    (builtins.fromJSON (builtins.readFile ./historical.json)).${pkgs.stdenv.hostPlatform.system};
  actual = import ./manifest.nix { inherit lib packages repository; };
  historicalUnchanged = lib.all (
    name:
    lib.all (snapshot: actual.${name}.${snapshot} == expected.${name}.${snapshot}) (
      builtins.attrNames expected.${name}
    )
  ) (builtins.attrNames expected);

  # Model the supported transition: a Java payload and a native payload with
  # different dependencies and channels, selected through distinct builders.
  builder =
    language:
    {
      version,
      src,
      dependencies,
    }:
    pkgs.runCommand "snapshot-fixture-${language}-${version}" {
      pname = "snapshot-fixture";
      inherit version;
      meta = {
        description = "Snapshot fixture";
        homepage = "https://example.org";
        license = lib.licenses.mit;
      };
      passthru = {
        snapshotMetarepo = metarepo;
        nativePublication = {
          maintainer = "Tests";
          payload = src;
          independent = language == "java";
          channels =
            if language == "java" then
              [
                "jammy"
                "arch"
              ]
            else
              [
                "noble"
                "fedora"
              ];
          formats = lib.genAttrs [ "apt" "dnf" "pacman" ] (format: {
            depends = dependencies.${format};
          });
        };
      };
    } "mkdir -p $out";
  old = {
    version = "1.0";
    source = pkgs.emptyDirectory;
    builder = builder "java";
    dependencies = {
      apt = [ "java8-runtime" ];
      dnf = [ "java" ];
      pacman = [ "java-runtime>=8" ];
    };
    publication.release = "1";
  };
  new = old // {
    version = "3.0";
    builder = builder "native";
    dependencies = {
      apt = [ "libc6" ];
      dnf = [ "glibc" ];
      pacman = [ "glibc" ];
    };
    publication.release = "2";
  };
  make =
    snapshots: default:
    metarepo.mkSnapshots {
      inherit snapshots default;
      source = snapshot: snapshot.source;
      build =
        args:
        args.builder (
          builtins.removeAttrs args [
            "source"
            "builder"
          ]
        );
    };
  before = make { "2026-10-11" = old; } "2026-10-11";
  after = make {
    "2026-10-11" = old;
    "2026-10-14" = new;
  } "2026-10-14";
  publication = import ../lib/publish-snapshots.nix {
    inherit lib repository;
    package = after;
  };
in
assert lib.assertMsg historicalUnchanged
  "FDCR: a historical recipe changed; add a new builder/snapshot instead";
assert before.snapshots."2026-10-11".drvPath == after.snapshots."2026-10-11".drvPath;
assert after.version == "3.0";
assert after.snapshots."2026-10-11".nativePublication.formats.apt.depends == [ "java8-runtime" ];
assert after.snapshots."2026-10-14".nativePublication.formats.apt.depends == [ "libc6" ];
assert after.snapshots."2026-10-14".publication.release == "2";
assert
  builtins.attrNames publication.channels == [
    "arch"
    "fedora"
    "jammy"
    "noble"
  ];
assert lib.all (artifacts: builtins.length artifacts == 1) (
  builtins.attrValues publication.channels
);
# Force native metadata/build recipes, including each format's architecture.
assert builtins.deepSeq (lib.mapAttrs (
  _: artifacts: map (a: a.drvPath) artifacts
) publication.channels) true;
pkgs.runCommand "fdcr-snapshot-regressions" { } "touch $out"
