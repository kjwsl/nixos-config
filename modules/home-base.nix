# Base Home Manager identity: username, homeDirectory, stateVersion,
# shell aliases, and nixpkgs overlays/config.
# Contributes to flake.modules.homeManager.base (all platforms).
{
  inputs,
  lib,
  ...
}: {
  flake.modules.homeManager.base = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
      inputs.catppuccin.homeModules.catppuccin
    ];

    home.username = lib.mkDefault "ray";
    home.homeDirectory = lib.mkDefault (
      if pkgs.stdenv.isDarwin
      then "/Users/ray"
      else "/home/ray"
    );

    home.shellAliases = {
      v = "nvim";
      "v." = "nvim .";
      g = "git";
    };

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less";
    };

    home.stateVersion = "25.05";
  };
}
