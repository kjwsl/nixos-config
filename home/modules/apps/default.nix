{ config, lib, pkgs, ... }:

with lib;

{
  # Import submodules directly at the top level
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
  
  # No option declarations here - they are already defined in the individual module files
}
