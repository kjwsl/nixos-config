{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.dev.tmux;
in
{
  options.ray.home.modules.dev.tmux = {
    enable = mkEnableOption "tmux terminal multiplexer";
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = mkForce true;
      plugins = with pkgs.tmuxPlugins; [
        catppuccin
        jump
        yank
        tmux-fzf
        sensible
        resurrect
        continuum
        mode-indicator
        vim-tmux-navigator
      ];
      mouse = true;
      prefix = "C-s";
      clock24 = true;
      keyMode = "vi";
    };
    
    home.packages = with pkgs; [
      tmux
    ];
  };
} 