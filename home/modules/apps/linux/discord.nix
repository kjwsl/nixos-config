{ config, lib, pkgs, ... }@inputs:
with lib;
let
  cfg = config.ray.home.modules.apps.discord;
in
{
  options.ray.home.modules.apps.discord = {
    enable = mkEnableOption "Discord App";
  };

  config = mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    home.packages = with pkgs;[
      discord
    ];
  };
}
