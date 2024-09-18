{ config, pkgs, lib, ... }:
with lib;
let
  nixvim = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixvim";
    # If you are not running an unstable channel of nixpkgs, select the corresponding branch of nixvim.
    # ref = "nixos-24.05";
  });
  cfg = config.ray.home.modules.dev.nixvim;
in
{
  imports = [
    nixvim.homeManagerModules.nixvim
  ];

  options.ray.home.modules.dev.nixvim =
    {
      enable = mkEnableOption "Nixvim Editor";
    };
  config = mkIf cfg.enable {

    programs.nixvim = {
      enable = true;
    };
  };
}
