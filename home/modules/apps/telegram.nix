{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.apps.telegram;
  # Only define Linux packages if we're on Linux
  telegramPackages = if pkgs.stdenv.isLinux then with pkgs; [
    telegram-desktop
  ] else [];
in
{
  options.ray.home.modules.apps.telegram = {
    enable = mkEnableOption "Telegram Desktop";
  };

  config = mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    home.packages = telegramPackages;
  };
} 