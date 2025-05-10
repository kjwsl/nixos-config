{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ray.home.profiles;
in
{
  options.ray.home.profiles.desktop = {
    enable = mkEnableOption "Desktop profile";
  };

  config = mkIf cfg.enable {
    ray.home.modules = {
      apps = {
        wezterm.enable = mkForce false;
        kitty.enable = mkForce false;
        rofi.enable = mkForce true;
        waybar.enable = mkForce true;
        discord.enable = mkForce true;
        telegram.enable = mkForce true;
        steam.enable = mkForce true;
        qbittorrent.enable = mkForce true;
      };
      shell = {
        fish.enable = mkForce false;
        zoxide.enable = mkForce true;
        bat.enable = mkForce true;
        eza.enable = mkForce true;
        fastfetch = {
          enable = mkForce true;
          theme = "catppuccin";
        };
      };
    };

    # Additional desktop-specific packages
    home.packages = with pkgs; [
      # Gaming
      steam-run
      protontricks
      winetricks
      lutris
      
      # Multimedia
      vlc
      mpv
      spotify
      
      # System utilities
      htop
      neofetch
      fastfetch
    ];
  };
}

