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
        wezterm.enable = true;
        kitty.enable = true;
        rofi.enable = true;
        waybar.enable = true;
        discord.enable = true;
        telegram.enable = true;
        steam.enable = true;
        qbittorrent.enable = true;
      };
      shell = {
        fish.enable = true;
        zoxide.enable = true;
        bat.enable = true;
        eza.enable = true;
        fastfetch = {
          enable = true;
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

