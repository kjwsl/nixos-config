{ config, pkgs, ... }:

{
  # Security settings
  security = {
    # Enable auditd
    auditd.enable = true;
    
    # Enable sudo
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
    };

    # Enable polkit
    polkit.enable = true;

    # Enable doas (alternative to sudo)
    doas = {
      enable = true;
      extraRules = [{
        users = [ "ray" ];
        keepEnv = true;
        persist = true;
      }];
    };

    # Enable apparmor
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
    };
  };

  # Firewall configuration
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
    allowedUDPPorts = [ ];
  };
} 