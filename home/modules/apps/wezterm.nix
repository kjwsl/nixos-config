{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.apps.wezterm;
in
{
  options.ray.home.modules.apps.wezterm = {
    enable = mkEnableOption "WezTerm terminal emulator";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wezterm
    ];
    
    xdg.configFile = {
      "wezterm/wezterm.lua" = {
        text = ''
          local wezterm = require 'wezterm'
          
          local config = {}
          
          if wezterm.config_builder then
            config = wezterm.config_builder()
          end
          
          -- Color scheme
          config.color_scheme = 'Catppuccin Mocha'
          
          -- Font configuration
          config.font = wezterm.font('JetBrainsMono Nerd Font')
          config.font_size = 12.0
          
          -- Window configuration
          config.window_background_opacity = 0.95
          config.window_padding = {
            left = 2,
            right = 2,
            top = 2,
            bottom = 2,
          }
          
          -- Tab bar configuration
          config.use_fancy_tab_bar = false
          config.hide_tab_bar_if_only_one_tab = true
          
          return config
        '';
      };
    };
  };
}
