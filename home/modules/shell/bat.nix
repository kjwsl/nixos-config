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
    home.packages = with pkgs; [
      bat
    ];

    # Configure bat
    programs.bat = {
      enable = true;
      config = {
        theme = "TwoDark";
        style = "numbers,changes,header";
        pager = "less -FR";
      };
    };
  };
}

