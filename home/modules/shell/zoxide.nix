{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.shell.zoxide;
in
{
  options.ray.home.modules.shell.zoxide = {
    enable = mkEnableOption "zoxide directory navigation";
  };

  config = mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };
    
    home.packages = with pkgs; [
      zoxide
    ];
  };
} 