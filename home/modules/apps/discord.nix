{ config, lib, pkgs, ... }@inputs:
with lib;
let
  cfg = config.ray.home.modules.apps.discord;
  # Only define Linux packages if we're on Linux
  discordPackages = if pkgs.stdenv.isLinux then with pkgs; [
    discord
  ] else [];
in
{
  options.ray.home.modules.apps.discord = {
    enable = mkEnableOption "Discord App";
  };

  config = mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    home.packages = discordPackages;
  };
}
