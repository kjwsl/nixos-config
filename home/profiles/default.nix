{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;

  # Define available profiles
  availableProfiles = {
    desktop = ./desktop.nix;
    development = ./development.nix;
    work = ./work.nix;
  };

  # Define available desktop environments
  availableDesktopEnvironments = {
    hyprland = ./desktop-environments/hyprland.nix;
    gnome = ./desktop-environments/gnome.nix;
  };
in
{
  options.ray.home = {
    profiles = {
      active = lib.mkOption {
        type = lib.types.enum (builtins.attrNames availableProfiles);
        default = "desktop";
        description = "The active profile to use";
      };
      desktopEnvironment = lib.mkOption {
        type = lib.types.enum (builtins.attrNames availableDesktopEnvironments);
        default = "gnome";
        description = "The active desktop environment to use";
      };
    };
  };

  config = lib.mkIf (config.ray.home.profiles.active != null) {
    imports = [
      (availableProfiles.${config.ray.home.profiles.active})
      (availableDesktopEnvironments.${config.ray.home.profiles.desktopEnvironment})
    ];
  };
}
