# Graphical desktop environment.
{pkgs, ...}: {
  # Display server
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # GNOME desktop (swap for your preferred DE)
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # OpenGL / GPU
  hardware.graphics.enable = true;
}
