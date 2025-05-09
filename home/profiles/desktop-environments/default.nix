{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.profiles.desktop-environments;
in
{
  options.ray.home.profiles.desktop-environments = {
    active = mkOption {
      type = types.enum [ "hyprland" "gnome" "kde" "xfce" ];
      default = "hyprland";
      description = "The active desktop environment to use";
    };
  };

  imports = [
    ./hyprland.nix
    ./gnome.nix
  ];

  config = {
    ray.home.profiles.desktop-environments.${cfg.active}.enable = true;
  };
} 