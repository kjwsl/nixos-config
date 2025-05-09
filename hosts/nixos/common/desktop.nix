{ config, pkgs, ... }:

{
  # Enable X11
  services.xserver.enable = true;

  # Enable GNOME
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable Hyprland
  programs.hyprland.enable = true;

  # Desktop-specific packages
  environment.systemPackages = with pkgs; [
    # Desktop applications
    brave
    discord
    wezterm
    lazygit
    fzf
    telegram-desktop
    steam
    qbittorrent
    zoxide
    code-cursor
    kitty
    rofi
    ibus
    ibus-engines.hangul
    ibus-engines.libpinyin
    ibus-engines.mozc
    libgcc
    oh-my-fish

    # Wine packages
    wineWowPackages.stable
    wine
    (wine.override { wineBuild = "wine64"; })
    wine64
    winetricks
    wineWowPackages.waylandFull
  ];

  # Enable Steam
  programs.steam = {
    enable = true;
    protontricks.enable = true;
  };

  # Enable Firefox
  programs.firefox.enable = true;
} 