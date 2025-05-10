{ config, lib, pkgs, ... }:

with lib;
{
  # Import all modules
  imports = [
    # Cross-platform modules
    ./wezterm.nix
    ./kitty.nix
    ./neovim.nix
    
    # Linux-specific modules
    ./rofi.nix
    ./waybar.nix
    ./discord.nix
    ./telegram.nix
    ./steam.nix
    ./qbittorrent.nix
  ];

  # On Darwin, explicitly disable Linux-only modules
  config = mkIf pkgs.stdenv.isDarwin {
    ray.home.modules.apps.rofi.enable = mkForce false;
    ray.home.modules.apps.waybar.enable = mkForce false;
    ray.home.modules.apps.discord.enable = mkForce false;
    ray.home.modules.apps.telegram.enable = mkForce false;
    ray.home.modules.apps.steam.enable = mkForce false;
    ray.home.modules.apps.qbittorrent.enable = mkForce false;
  };
}
