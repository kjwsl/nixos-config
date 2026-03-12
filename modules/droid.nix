# Builds flake.nixOnDroidConfigurations from the configurations.nixOnDroid option.
# Each entry's module is a deferredModule — defined in modules/hosts/droid.nix.
{
  inputs,
  lib,
  config,
  ...
}: {
  options.configurations.nixOnDroid = lib.mkOption {
    type = lib.types.lazyAttrsOf (lib.types.submodule {
      options.module = lib.mkOption {type = lib.types.deferredModule;};
    });
    default = {};
  };

  config.flake.nixOnDroidConfigurations = lib.mapAttrs (name: cfg:
    inputs.nix-on-droid.lib.nixOnDroidConfiguration {
      pkgs = import inputs.nixpkgs {
        system = "aarch64-linux";
        config.allowUnfree = true;
        overlays = [
          inputs.neovim-nightly-overlay.overlays.default
          inputs.nur.overlays.default
        ];
      };
      modules = [cfg.module];
      extraSpecialArgs = {inherit inputs;};
      home-manager-path = inputs.home-manager;
    })
  config.configurations.nixOnDroid;
}
