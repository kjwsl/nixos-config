# Builds flake.nixosConfigurations from the configurations.nixos option.
# Each entry's module is a deferredModule — defined in modules/hosts/*.nix.
{
  inputs,
  lib,
  config,
  ...
}: {
  options.configurations.nixos = lib.mkOption {
    type = lib.types.lazyAttrsOf (lib.types.submodule {
      options.module = lib.mkOption {type = lib.types.deferredModule;};
    });
    default = {};
  };

  config.flake.nixosConfigurations = lib.mapAttrs (name: cfg:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [cfg.module];
    })
  config.configurations.nixos;
}
