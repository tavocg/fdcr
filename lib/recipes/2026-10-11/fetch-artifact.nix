# Vendor artifacts are stored with Git LFS, but flake inputs fetched from
# GitHub unpack the LFS pointer file, not the real bytes. Download the content
# from the LFS media endpoint, pinned by commit and the vendor SHA-256, and pin
# it by content with `builtins.path`. The resulting store path is identical to
# the one a local `git lfs pull` checkout yields, so historical derivations
# (and `tests/historical.json`) do not drift.
{
  owner,
  repo,
  rev,
  path,
  sha256,
}:
let
  name = builtins.baseNameOf path;
  fetched = builtins.fetchurl {
    url = "https://media.githubusercontent.com/media/${owner}/${repo}/${rev}/${path}";
    inherit name sha256;
  };
in
builtins.path {
  path = fetched;
  inherit name;
}
