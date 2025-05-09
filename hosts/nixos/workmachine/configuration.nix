{ config, pkgs, ... }:

{
  imports = [
    # Common configurations
    ../common/default.nix
    ../common/desktop.nix
    ../common/users.nix
    ../common/hardware.nix
    ../common/security.nix
    ../common/development.nix
  ] ++ (if builtins.pathExists ./hardware-configuration.nix then [ ./hardware-configuration.nix ] else []);

  # Hostname
  networking.hostName = "workmachine";

  # Time zone
  time.timeZone = "Asia/Seoul";

  # Work-specific packages
  environment.systemPackages = with pkgs; [
    # Add work-specific packages here
    slack
    zoom-us
    teams
    libreoffice
  ];

  # Work-specific services
  services = {
    # Enable printing
    printing = {
      enable = true;
      drivers = with pkgs; [ gutenprint ];
    };
  };

  # System version
  system.stateVersion = "24.11";
} 