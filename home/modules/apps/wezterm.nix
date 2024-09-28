{ config, lib, pkgs, flakeContext, ... }:

with lib;
let
  cfg = config.larp.app.wezterm;
  config_dir = flakeContext.conf_dir;
in
{
  options.larp.app.wezterm = {
    enable = mkEnableOption "Wezterm Configuration";
  };

  config = mkIf cfg.enable {
    xdg.configFile."wezterm".source = "${config_dir}/.config/wezterm";
    programs.wezterm.enable = true;
  };

}
