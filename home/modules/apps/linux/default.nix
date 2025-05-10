{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.apps;
in
{
  imports = [
    ./discord.nix
    ./telegram.nix
    ./steam.nix
    ./qbittorrent.nix
    ./rofi.nix
    ./waybar.nix
  ];

  # Only enable these modules if we're on Linux
  config = mkIf pkgs.stdenv.isLinux {
    # No additional configuration needed - 
    # the imported modules will handle their own conditions
  };
} 