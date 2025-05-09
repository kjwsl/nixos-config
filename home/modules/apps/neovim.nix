{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.apps.neovim;
in
{
  options.ray.home.modules.apps.neovim = {
    enable = mkEnableOption "Neovim editor";
  };

  config = mkIf cfg.enable {
    # Basic neovim setup
    home.packages = with pkgs; [
      neovim
      neovim-remote
    ];
    
    home.shellAliases = {
      vi = "nvim";
      vim = "nvim";
    };
    
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
} 