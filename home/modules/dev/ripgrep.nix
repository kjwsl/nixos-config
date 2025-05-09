{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.dev.ripgrep;
in
{
  options.ray.home.modules.dev.ripgrep = {
    enable = mkEnableOption "ripgrep search tool";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ripgrep
    ];
  };
} 