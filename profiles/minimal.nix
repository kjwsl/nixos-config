# Minimal profile - Just shell and basic tools
{ config, pkgs, ... }:

{
  imports = [
    ./base.nix
  ];

  # Minimal additional packages
  home.packages = with pkgs; [
    fzf
    zoxide
  ];
}
