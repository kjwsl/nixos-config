{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.dev.tmux;
in
{
  options.ray.home.modules.dev.tmux = {
    enable = mkEnableOption "tmux terminal multiplexer" // { default = false; };
  };

  config = mkMerge [
    (mkIf false {}) # Always disabled, no config
    (mkIf cfg.enable {
      home.packages = with pkgs; [
        tmux
        tmuxPlugins.catppuccin
        tmuxPlugins.jump
        tmuxPlugins.yank
        tmuxPlugins.tmux-fzf
        tmuxPlugins.sensible
        tmuxPlugins.resurrect
        tmuxPlugins.continuum
        tmuxPlugins.mode-indicator
        tmuxPlugins.vim-tmux-navigator
      ];
    })
  ];
} 