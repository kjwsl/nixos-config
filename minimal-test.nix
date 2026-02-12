{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    git
    fish
    starship
  ];

  programs.git = {
    enable = true;
    userName = "ray";
    userEmail = "kjwsl@fatherslab.com";
  };

  programs.fish.enable = true;
  programs.starship.enable = true;

  home.stateVersion = "25.05";
}