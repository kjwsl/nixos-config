{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.shell.fish;
in
{
  options.ray.home.modules.shell.fish = {
    enable = mkEnableOption "Fish shell";
  };

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
      plugins = [
        {
          name = "oh-my-fish";
          src = pkgs.oh-my-fish;
        }
      ];
      shellAliases = {
        g = "git";
        ls = "ls -ah --color";
        ll = "ls -lah --color";
      };
    };
    
    home.packages = with pkgs; [
      oh-my-fish
    ];
  };
} 