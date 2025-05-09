{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.profiles.desktop-environments.gnome;
in
{
  options.ray.home.profiles.desktop-environments.gnome = {
    enable = mkEnableOption "GNOME desktop environment";
  };

  config = mkIf cfg.enable {
    # Enable GNOME
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        enable-hot-corners = true;
        show-battery-percentage = true;
      };
      "org/gnome/desktop/peripherals/touchpad" = {
        natural-scroll = true;
        tap-to-click = true;
        two-finger-scrolling-enabled = true;
      };
      "org/gnome/desktop/wm/keybindings" = {
        switch-applications = [ "<Super>Tab" ];
        switch-applications-backward = [ "<Shift><Super>Tab" ];
        switch-windows = [ "<Alt>Tab" ];
        switch-windows-backward = [ "<Shift><Alt>Tab" ];
        close = [ "<Super>q" ];
        maximize = [ "<Super>Up" ];
        unmaximize = [ "<Super>Down" ];
        minimize = [ "<Super>h" ];
        move-to-workspace-1 = [ "<Super><Shift>1" ];
        move-to-workspace-2 = [ "<Super><Shift>2" ];
        move-to-workspace-3 = [ "<Super><Shift>3" ];
        move-to-workspace-4 = [ "<Super><Shift>4" ];
        switch-to-workspace-1 = [ "<Super>1" ];
        switch-to-workspace-2 = [ "<Super>2" ];
        switch-to-workspace-3 = [ "<Super>3" ];
        switch-to-workspace-4 = [ "<Super>4" ];
      };
      "org/gnome/shell" = {
        favorite-apps = [
          "org.gnome.Nautilus.desktop"
          "kitty.desktop"
          "firefox.desktop"
          "org.gnome.Calendar.desktop"
          "org.gnome.Settings.desktop"
        ];
        enabled-extensions = [
          "appindicatorsupport@rgcjonas.gmail.com"
          "blur-my-shell@aunetx"
          "dash-to-dock@micxgx.gmail.com"
          "just-perfection-desktop@just-perfection"
          "user-theme@gnome-shell-extensions.gcampax.github.com"
        ];
      };
      "org/gnome/shell/extensions/dash-to-dock" = {
        dock-position = "BOTTOM";
        extend-height = false;
        dock-fixed = true;
        transparency-mode = "FIXED";
        dash-max-icon-size = 32;
        show-apps-at-top = true;
        show-trash = true;
        show-mounts = true;
        show-favorites = true;
      };
      "org/gnome/shell/extensions/just-perfection" = {
        activities-button-icon-monochrome = true;
        app-menu-icon = true;
        app-menu-label = true;
        clock-menu-position = 1;
        clock-menu-position-offset = 7;
        controls-manager-spacing-size = 0;
        keyboard-layout = true;
        notification-banner-position = 2;
        panel = true;
        panel-in-overview = true;
        power-icon = true;
        quick-settings-menu-position = 1;
        search = true;
        show-apps-button = true;
        startup-status = 0;
        window-picker-icon = true;
        window-picker-show-all-workspaces = true;
        workspace = true;
        workspace-wrap-around = true;
      };
      "org/gnome/shell/extensions/blur-my-shell" = {
        brightness = 0.8;
        sigma = 30;
        style-panel = true;
        style-dash = true;
        style-overview = true;
        style-applications = true;
        style-appfolders = true;
        style-workspaces = true;
      };
      "org/gnome/desktop/background" = {
        picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-day.jpg";
        picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-night.jpg";
      };
      "org/gnome/desktop/screensaver" = {
        picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-night.jpg";
      };
    };

    # Enable required services
    services = {
      # Enable GNOME services
      gnome = {
        core-utilities.enable = true;
        core-shell.enable = true;
        games.enable = false;
        tracker.enable = true;
        tracker-miners.enable = true;
      };

      # Enable network manager applet
      network-manager-applet.enable = true;

      # Enable blueman
      blueman-applet.enable = true;

      # Enable gvfs
      gvfs.enable = true;
    };

    # Enable required packages
    home.packages = with pkgs; [
      # GNOME packages
      gnome-tweaks
      gnome-shell-extensions
      gnome.gnome-terminal
      gnome.gnome-calculator
      gnome.gnome-calendar
      gnome.gnome-maps
      gnome.gnome-weather
      gnome.gnome-system-monitor
      gnome.gnome-disk-utility
      gnome-screenshot
      gnome.gnome-sound-recorder
      gnome.gnome-clocks
      gnome.gnome-contacts
      gnome.gnome-music
      gnome.gnome-photos
      gnome.gnome-software
      gnome.gnome-terminal
      gnome.gnome-tour
      gnome.gnome-user-docs
      gnome.gnome-user-share
      gnome.gnome-video-effects
      gnome.gnome-weather
      gnome.gnome-characters
      gnome.gnome-color-manager
      gnome.gnome-control-center
      gnome.gnome-disk-utility
      gnome.gnome-documents
      gnome.gnome-font-viewer
      gnome.gnome-logs
      gnome.gnome-power-manager
      gnome.gnome-session
      gnome.gnome-settings-daemon
      gnome.gnome-shell
      gnome-shell-extensions
      gnome.gnome-software
      gnome.gnome-system-monitor
      gnome.gnome-terminal
      gnome-tweaks
      gnome.gnome-user-docs
      gnome.gnome-user-share
      gnome.gnome-video-effects
      gnome.gnome-weather

      # System utilities
      networkmanagerapplet
      blueman
      polkit_gnome
      gvfs
    ];

    # Enable required modules
    ray.home.modules = {
      apps = {
        waybar.enable = false;  # Disable waybar as it's not needed in GNOME
        rofi.enable = false;    # Disable rofi as it's not needed in GNOME
      };
    };
  };
} 