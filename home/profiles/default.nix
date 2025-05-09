{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.profiles;
in
{
  options.ray.home.profiles = {
    active = mkOption {
      type = types.enum [ "desktop" "development" "work" ];
      default = "desktop";
      description = "The active profile to use";
    };
  };

  imports = [
    ./desktop.nix
    ./development.nix
    ./work.nix
    ./desktop-environments
  ];

  config = {
    ray.home.profiles.${cfg.active}.enable = true;
  };
}
