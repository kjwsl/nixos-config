self: super: {
  # GNOME customizations
  gnome = super.gnome.overrideScope' (gnome-self: gnome-super: {
    # Override GNOME Shell with custom patches
    gnome-shell = gnome-super.gnome-shell.overrideAttrs (old: {
      patches = (old.patches or []) ++ [
        # Add custom patches here
        ./patches/gnome-shell/custom-workspace.patch
      ];
    });

    # Override GNOME Terminal with custom settings
    gnome-terminal = gnome-super.gnome-terminal.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        # Add custom terminal profiles
        mkdir -p $out/share/gnome-terminal/colors
        cp ${./config/terminal/colors} $out/share/gnome-terminal/colors/custom
      '';
    });
  });

  # Hyprland customizations
  hyprland = super.hyprland.overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      # Add custom patches here
      ./patches/hyprland/custom-animations.patch
    ];
  });

  # Custom desktop utilities
  desktop-utils = super.symlinkJoin {
    name = "desktop-utils";
    paths = with super; [
      # Screenshot tools
      grim
      slurp
      wl-clipboard
      
      # System monitors
      htop
      btop
      
      # File managers
      nautilus
      dolphin
      
      # Media players
      mpv
      vlc
    ];
  };
} 