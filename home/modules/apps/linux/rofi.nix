{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.apps.rofi;
in
{
  options.ray.home.modules.apps.rofi = {
    enable = mkEnableOption "rofi application launcher";
  };

  config = mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    home.packages = with pkgs; [
      rofi
      rofi-calc
      rofi-emoji
      rofi-power-menu
    ];
    
    xdg.configFile = {
      "rofi/config.rasi" = {
        text = ''
          configuration {
            modi: "drun,window,run,ssh,combi";
            theme: "catppuccin-mocha";
            show-icons: true;
            terminal: "wezterm";
            drun-display-format: "{name}";
            sidebar-mode: true;
          }
        '';
      };
    };
  };
} 