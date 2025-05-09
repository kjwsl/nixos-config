{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.apps.telegram;
in
{
  options.ray.home.modules.apps.telegram = {
    enable = mkEnableOption "Telegram Desktop";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      telegram-desktop
    ];
  };
} 