{ config, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in
{
  # Linux-specific configurations using native HM modules where available
  wayland.windowManager.hyprland = lib.mkIf isLinux {
    enable = true;
    # Note: Hyprland config is complex and might be better as file for now
    # We can nixify specific parts over time
  };
  
  programs.waybar = lib.mkIf isLinux {
    enable = true;
    # Note: Waybar config is complex JSON, manage as file for now
  };

  # Platform-specific and cross-platform file configurations
  home.file = lib.mkMerge [
    # macOS-specific configurations
    (lib.mkIf isDarwin {
      # AeroSpace (macOS window manager)
      ".config/aerospace".source = ../dotfiles/aerospace;
      
      # SketchyBar (macOS menu bar)
      ".config/sketchybar".source = ../dotfiles/sketchybar;
      
      # Karabiner Elements (macOS key remapping)
      ".config/karabiner".source = ../dotfiles/karabiner;
    })

    # Linux-specific configurations
    (lib.mkIf isLinux {
      # Hyprland configuration (complex, keep as file for now)
      ".config/hypr".source = ../dotfiles/hypr;
      
      # Waybar configuration (complex JSON, keep as file)
      ".config/waybar".source = ../dotfiles/waybar;
      
      # EWW widget system (complex, keep as file)
      ".config/eww".source = ../dotfiles/eww;
      
      # Desktop environment configurations
      ".config/cinnamon".source = ../dotfiles/cinnamon;
      ".config/fontconfig".source = ../dotfiles/fontconfig;
      ".config/gtk-3.0".source = ../dotfiles/gtk-3.0;
      ".config/gtk-4.0".source = ../dotfiles/gtk-4.0;
      
      # System integration
      ".config/xdg-desktop-portal".source = ../dotfiles/xdg-desktop-portal;
      ".config/ibus".source = ../dotfiles/ibus;
      ".config/nemo".source = ../dotfiles/nemo;
      ".config/menus".source = ../dotfiles/menus;
      
      # Status bars and widgets
      ".config/yasb".source = ../dotfiles/yasb;
    })

    # Cross-platform configurations
    {
      # Audio production plugins (cross-platform)
      ".vst".source = ../dotfiles/dot_vst;
      ".vst3".source = ../dotfiles/dot_vst3;
      ".clap".source = ../dotfiles/dot_clap;
    }
  ];

  # Platform-specific shell configuration additions
  programs.fish.shellInit = lib.mkAfter (
    if isDarwin then ''
      # macOS-specific Fish configuration
      # Add any macOS-specific paths or settings here
    ''
    else if isLinux then ''
      # Linux-specific Fish configuration
      # Add any Linux-specific paths or settings here
    ''
    else ""
  );
}