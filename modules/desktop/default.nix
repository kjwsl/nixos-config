# Desktop environment module.
# Enables GNOME as the default compositor with optional Hyprland support.
# Also sets up XDG portals, keyboard layout, and browser defaults.
{
  config,
  lib,
  pkgs,
  ...
}: {
  options.my.desktop = {
    hyprland.enable = lib.mkEnableOption "Hyprland Wayland compositor (alongside GNOME)";
  };

  config = {
    # X11 server (needed for GNOME and XWayland)
    services.xserver.enable = true;

    # GNOME desktop
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    # Keyboard layout
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # XDG desktop portals
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
      ];
    };

    # Optional Hyprland compositor
    programs.hyprland.enable = lib.mkIf config.my.desktop.hyprland.enable true;
    programs.hyprland.xwayland.enable = lib.mkIf config.my.desktop.hyprland.enable true;

    # Firefox as default browser
    programs.firefox.enable = true;

    # Catppuccin theming for fcitx5 (input method)
    i18n.inputMethod = {
      type = "fcitx5";
      enable = true;
      fcitx5.addons = with pkgs; [
        fcitx5-hangul
        fcitx5-mozc
        fcitx5-gtk
        fcitx5-rime
        catppuccin-fcitx5
      ];
    };
  };
}
