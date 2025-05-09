{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.apps.kitty;
in
{
  options.ray.home.modules.apps.kitty = {
    enable = mkEnableOption "Kitty terminal emulator";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      kitty
    ];
    
    xdg.configFile = {
      "kitty/kitty.conf" = {
        text = ''
          # Theme (using built-in Catppuccin Mocha theme)
          include ${pkgs.kitty}/share/kitty/themes/Catppuccin-Mocha.conf
          
          # Font settings
          font_family JetBrainsMono Nerd Font
          font_size 12
          
          # General settings
          scrollback_lines 10000
          enable_audio_bell no
          update_check_interval 0
          background_opacity 0.95
          confirm_os_window_close 0
        '';
      };
    };
  };
} 