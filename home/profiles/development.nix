{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.profiles.development;
in
{
  options.ray.home.profiles.development = {
    enable = mkEnableOption "Development profile";
  };

  config = mkIf cfg.enable {
    ray.home.modules = {
      apps = {
        wezterm.enable = true;
        kitty.enable = true;
        neovim.enable = true;
      };
      shell = {
        fish.enable = true;
        zoxide.enable = true;
        bat.enable = true;
        eza.enable = true;
      };
      dev = {
        git.enable = true;
        tmux.enable = true;
        fzf.enable = true;
        ripgrep.enable = true;
        rust.enable = true;
        nodejs.enable = true;
        pyenv.enable = true;
      };
    };
  };
} 