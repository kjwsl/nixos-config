# Builds flake.darwinConfigurations from the configurations.darwin option.
# Each entry's module is a deferredModule — defined in modules/hosts/*.nix.
{
  inputs,
  lib,
  config,
  ...
}: {
  options.configurations.darwin = lib.mkOption {
    type = lib.types.lazyAttrsOf (lib.types.submodule {
      options.module = lib.mkOption {type = lib.types.deferredModule;};
    });
    default = {};
  };

  config.flake.darwinConfigurations = lib.mapAttrs (name: cfg:
    inputs.darwin.lib.darwinSystem {
      inherit inputs;
      system = "aarch64-darwin";
      modules = [cfg.module];
    })
  config.configurations.darwin;
}
