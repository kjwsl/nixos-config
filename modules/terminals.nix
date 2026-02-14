{ config, pkgs, ... }:

{
  # WezTerm - GPU-accelerated terminal emulator
  # Note: Installed via homebrew cask in darwin.nix as "wezterm@nightly"
  # We just manage the config files here

  home.file = {
    # WezTerm config (Lua-based with modules)
    ".config/wezterm/wezterm.lua".source = ../config/wezterm/wezterm.lua;
    ".config/wezterm/utils.lua".source = ../config/wezterm/utils.lua;
    ".config/wezterm/.stylua".source = ../config/wezterm/.stylua;
    ".config/wezterm/bg.jpg".source = ../config/wezterm/bg.jpg;
    ".config/wezterm/modules".source = ../config/wezterm/modules;
  };

  # Alacritty - Alternative terminal (if you use it)
  # programs.alacritty = {
  #   enable = true;
  #   settings = {
  #     # Configuration here
  #   };
  # };
}
