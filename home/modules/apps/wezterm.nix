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
    programs.wezterm = {
      enable = true;
    };
    
    home.packages = with pkgs; [
      wezterm
    ];
  };
}
