{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.apps.steam;
in
{
  options.ray.home.modules.apps.steam = {
    enable = mkEnableOption "Steam gaming platform";
  };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;
      protontricks.enable = true;
    };
    
    home.packages = with pkgs; [
      steam
    ];
  };
} 