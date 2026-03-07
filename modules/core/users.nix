# Core user definitions.
# Defines the primary system user "aileron" and enables the fish shell system-wide.
{pkgs, ...}: {
  users.users.aileron = {
    isNormalUser = true;
    description = "aileron";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "audio"
      "video"
    ];
    shell = pkgs.fish;
  };

  # fish must be enabled at the system level so login shells work
  programs.fish.enable = true;
}
