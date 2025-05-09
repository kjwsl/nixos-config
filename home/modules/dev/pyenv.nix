{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.dev.pyenv;
in
{
  options.ray.home.modules.dev.pyenv = {
    enable = mkEnableOption "pyenv Python version manager";
  };

  config = mkIf cfg.enable {
    programs.pyenv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };
    
    home.packages = with pkgs; [
      pyenv
      python3
      python3Packages.pip
      python3Packages.setuptools
      python3Packages.wheel
    ];
  };
} 