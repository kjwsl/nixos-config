# Base profile - Shared across all profiles
{ config, pkgs, ... }:

{
  imports = [
    ../modules/shell.nix
    ../modules/starship.nix
    ../modules/git.nix
  ];

  # Essential packages everyone needs
  home.packages = with pkgs; [
    # Core utilities
    ripgrep
    fd
    bat
    eza
    jujutsu
    git-absorb

    # Basic tools
    htop
    btop
    tree
  ];

  home.stateVersion = "25.05";
}
