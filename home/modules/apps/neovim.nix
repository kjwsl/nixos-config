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
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      withNodeJs = true;
      withRuby = true;
      withPython3 = true;
      defaultEditor = true;
    };
    
    home.packages = with pkgs; [
      neovim
      neovim-remote
    ];
  };
} 