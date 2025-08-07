{ config, pkgs, ... }:
{
  home.packages = [
    pkgs.git
    pkgs.neovim
    pkgs.fastfetch
  ];

  home.stateVersion = "25.05";
}
