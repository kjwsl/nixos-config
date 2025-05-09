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
    home.packages = with pkgs; [
      eza
    ];
    
    home.shellAliases = {
      ls = lib.mkForce "eza --group-directories-first --icons";
      ll = lib.mkForce "eza --group-directories-first --icons -la";
      lt = "eza --group-directories-first --icons -T";
      la = "eza --group-directories-first --icons -a";
      l = "eza --group-directories-first --icons -l";
      
      lsg = "eza --group-directories-first --icons --git";
      llg = "eza --group-directories-first --icons -la --git";
    };
  };
} 