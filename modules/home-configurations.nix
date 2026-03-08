# Standalone homeConfigurations entries for use without NixOS/Darwin.
# References flake.modules.homeManager.base which is built up by all feature modules.
{config, ...}: {
  configurations.home = {
    linux = {
      system = "x86_64-linux";
      module = config.flake.modules.homeManager.base;
    };
    darwin = {
      system = "aarch64-darwin";
      module = config.flake.modules.homeManager.base;
    };
    termux = {
      system = "aarch64-linux";
      homeDirectory = "/data/data/com.termux.nix/files/home";
      module = config.flake.modules.homeManager.base;
    };
  };
}
