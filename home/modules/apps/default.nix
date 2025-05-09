{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ray.home.modules.apps;
in
{
  options.ray.home.modules.apps = {
    wezterm.enable = mkEnableOption "WezTerm terminal emulator";
    kitty.enable = mkEnableOption "Kitty terminal emulator";
    neovim.enable = mkEnableOption "Neovim text editor";
    discord.enable = mkEnableOption "Discord chat application";
    telegram.enable = mkEnableOption "Telegram messaging app";
    steam.enable = mkEnableOption "Steam gaming platform";
    qbittorrent.enable = mkEnableOption "qBittorrent torrent client";
    rofi.enable = mkEnableOption "Rofi application launcher";
    waybar.enable = mkEnableOption "Waybar status bar";
  };

  config = mkIf (cfg.wezterm.enable || cfg.kitty.enable || cfg.neovim.enable || 
                cfg.discord.enable || cfg.telegram.enable || cfg.steam.enable || 
                cfg.qbittorrent.enable || cfg.rofi.enable || cfg.waybar.enable) {
    imports = [
      ./wezterm.nix
      ./kitty.nix
      ./neovim.nix
      ./discord.nix
      ./telegram.nix
      ./steam.nix
      ./qbittorrent.nix
      ./rofi.nix
      ./waybar.nix
    ];
  };
}
