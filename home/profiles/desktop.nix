{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ray.home.profiles.desktop;
in
{
  options.ray.home.profiles.desktop = {
    enable = mkEnableOption "Desktop Profile";
  };

  config = mkIf cfg.enable {
    ray.home.modules = {
      apps = {
        wezterm.enable = true;
        discord.enable = true;
      };
      dev = {
        neovim.enable = true;
      };
      shell = {
        bat.enable = true;
      };
    };
  };
}

