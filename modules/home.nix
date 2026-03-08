# Builds flake.homeConfigurations from the configurations.home option.
# Each entry specifies a system and a deferredModule.
# The email and username top-level options are passed down via extraSpecialArgs,
# sourced from config.* so there is no specialArgs pass-thru at the call site.
{
  inputs,
  lib,
  config,
  ...
}: {
  options.configurations.home = lib.mkOption {
    type = lib.types.lazyAttrsOf (lib.types.submodule {
      options = {
        system = lib.mkOption {type = lib.types.singleLineStr;};
        homeDirectory = lib.mkOption {
          type = lib.types.nullOr lib.types.singleLineStr;
          default = null;
        };
        module = lib.mkOption {type = lib.types.deferredModule;};
      };
    });
    default = {};
  };

  config.flake.homeConfigurations = lib.mapAttrs (name: cfg:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        system = cfg.system;
        config.allowUnfree = true;
        overlays = [inputs.neovim-nightly-overlay.overlays.default];
      };
      modules =
        [cfg.module]
        ++ lib.optional (cfg.homeDirectory != null) {
          home.homeDirectory = lib.mkForce cfg.homeDirectory;
        };
    })
  config.configurations.home;
}
