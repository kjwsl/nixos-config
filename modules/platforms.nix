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
      ".config/aerospace".source = ~/.local/share/chezmoi/dot_config/aerospace;
      
      # SketchyBar (macOS menu bar)
      ".config/sketchybar".source = ~/.local/share/chezmoi/dot_config/sketchybar;
      
      # Karabiner Elements (macOS key remapping)
      ".config/karabiner".source = ~/.local/share/chezmoi/dot_config/karabiner;
    })

    # Linux-specific configurations
    (lib.mkIf isLinux {
      # Hyprland configuration (complex, keep as file for now)
      ".config/hypr".source = ~/.local/share/chezmoi/dot_config/hypr;
      
      # Waybar configuration (complex JSON, keep as file)
      ".config/waybar".source = ~/.local/share/chezmoi/dot_config/waybar;
      
      # EWW widget system (complex, keep as file)
      ".config/eww".source = ~/.local/share/chezmoi/dot_config/eww;
      
      # Desktop environment configurations
      ".config/cinnamon".source = ~/.local/share/chezmoi/dot_config/cinnamon;
      ".config/fontconfig".source = ~/.local/share/chezmoi/dot_config/fontconfig;
      ".config/gtk-3.0".source = ~/.local/share/chezmoi/dot_config/gtk-3.0;
      ".config/gtk-4.0".source = ~/.local/share/chezmoi/dot_config/gtk-4.0;
      
      # System integration
      ".config/xdg-desktop-portal".source = ~/.local/share/chezmoi/dot_config/xdg-desktop-portal;
      ".config/ibus".source = ~/.local/share/chezmoi/dot_config/ibus;
      ".config/nemo".source = ~/.local/share/chezmoi/dot_config/nemo;
      ".config/menus".source = ~/.local/share/chezmoi/dot_config/menus;
      
      # Status bars and widgets
      ".config/yasb".source = ~/.local/share/chezmoi/dot_config/yasb;
    })

    # Cross-platform configurations
    {
      # Audio production plugins (cross-platform)
      ".vst".source = ~/.local/share/chezmoi/dot_vst;
      ".vst3".source = ~/.local/share/chezmoi/dot_vst3;
      ".clap".source = ~/.local/share/chezmoi/dot_clap;
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