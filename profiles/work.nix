# Work profile - Development + work-specific tools
{ config, pkgs, ... }:

{
  imports = [
    ./development.nix
  ];

  # Work-specific packages
  home.packages = with pkgs; [
    # Add work-specific tools here
    # slack (if in nixpkgs)
    # teams
    # etc.
  ];

  # Work-specific git config
  programs.git.extraConfig = {
    # Uncomment and configure for work
    # user.email = "you@work.com";
  };

  # Work-specific fish init
  programs.fish.interactiveShellInit = ''
    # Work-specific environment
    # set -gx WORK_PROJECT_DIR "$HOME/work"
  '';
}
