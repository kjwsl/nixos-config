{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.apps.rofi;
in
{
  options.ray.home.modules.apps.rofi = {
    enable = mkEnableOption "rofi application launcher";
  };

  config = mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      theme = "catppuccin-mocha";
      plugins = with pkgs; [
        rofi-calc
        rofi-emoji
        rofi-power-menu
      ];
    };
    
    home.packages = with pkgs; [
      rofi
      rofi-calc
      rofi-emoji
      rofi-power-menu
    ];
  };
} 