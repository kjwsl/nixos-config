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
    programs.kitty = {
      enable = true;
      theme = "Catppuccin-Mocha";
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 12;
      };
      settings = {
        scrollback_lines = 10000;
        enable_audio_bell = false;
        update_check_interval = 0;
        background_opacity = "0.95";
        confirm_os_window_close = 0;
      };
    };
    
    home.packages = with pkgs; [
      kitty
    ];
  };
} 