{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.shell.eza;
in
{
  options.ray.home.modules.shell.eza = {
    enable = mkEnableOption "eza better ls";
  };

  config = mkIf cfg.enable {
    programs.eza = {
      enable = true;
      enableAliases = true;
      git = true;
      icons = true;
      extraOptions = [
        "--group-directories-first"
        "--header"
      ];
    };
    
    home.packages = with pkgs; [
      eza
    ];
  };
} 