# Personal profile - Development + personal tools
{ config, pkgs, ... }:

{
  imports = [
    ./development.nix
  ];

  # Personal-specific packages
  home.packages = with pkgs; [
    # Media/entertainment tools
    # youtube-dl
    # ffmpeg
    # etc.
  ];

  # Personal git config
  programs.git.extraConfig = {
    # Personal email already configured in git.nix
  };
}
