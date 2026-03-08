# Core user definitions.
# Defines the primary system user "ray" and enables the fish shell system-wide.
{pkgs, ...}: {
  users.users.ray = {
    isNormalUser = true;
    description = "ray";
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
