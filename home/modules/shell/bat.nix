{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ray.home.modules.shell.bat;
in
{
  options.ray.home.modules.shell.bat = {
    enable = mkEnableOption "bat - a cat clone with syntax highlighting";
  };

  config = mkIf cfg.enable {
    # Use home.packages instead of programs.bat
    home.packages = with pkgs; [
      bat
    ];

    # Configure bat using environment variables
    home.sessionVariables = {
      BAT_THEME = "TwoDark";
      BAT_STYLE = "numbers,changes,header";
      BAT_PAGER = "less -FR";
    };

    # Add bat configuration file
    xdg.configFile = {
      "bat/config" = {
        text = ''
          # Bat configuration
          --theme="TwoDark"
          --style="numbers,changes,header"
          --pager="less -FR"
          --map-syntax "*.conf:INI"
          --map-syntax ".gitconfig:INI"
          --map-syntax "*.nix:Rust"
        '';
      };
    };
    
    # Add aliases
    home.shellAliases = {
      cat = "bat";
      less = "bat";
    };
  };
}

