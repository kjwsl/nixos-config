# Development tools available system-wide on NixOS.
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    git
    gnumake
    gcc
    pkg-config
  ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
}
