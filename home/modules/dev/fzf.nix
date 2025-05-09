{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.dev.fzf;
in
{
  options.ray.home.modules.dev.fzf = {
    enable = mkEnableOption "fzf fuzzy finder";
  };

  config = mkIf cfg.enable {
    programs.fzf = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      defaultCommand = "fd --type f";
      defaultOptions = [ "--height 40%" "--border" ];
      fileWidgetCommand = "fd --type f";
      fileWidgetOptions = [ "--preview 'bat --color=always --style=numbers --line-range=:500 {}'" ];
    };
    
    home.packages = with pkgs; [
      fzf
      fd
    ];
  };
} 