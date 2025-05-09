{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.dev.nodejs;
in
{
  options.ray.home.modules.dev.nodejs = {
    enable = mkEnableOption "Node.js development tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nodejs_22
      nodePackages.npm
      nodePackages.typescript
      nodePackages.typescript-language-server
    ];
  };
} 