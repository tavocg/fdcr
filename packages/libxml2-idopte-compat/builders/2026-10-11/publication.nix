{ package }:
{
  options = {
    channels = [ "noble" ];
    payload = package;
    maintainer = "FDCR package maintainers";
    license = "MIT";
    overrides.noble.depends = package.dependencies.noble;
  };
}
