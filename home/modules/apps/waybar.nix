{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.apps.waybar;
in
{
  options.ray.home.modules.apps.waybar = {
    enable = mkEnableOption "waybar status bar";
  };

  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 30;
          spacing = 4;
          margin-top = 2;
          margin-bottom = 2;
          margin-left = 2;
          margin-right = 2;
          modules-left = [
            "hyprland/workspaces"
            "hyprland/window"
          ];
          modules-center = [
            "clock"
          ];
          modules-right = [
            "pulseaudio"
            "network"
            "cpu"
            "memory"
            "temperature"
            "battery"
            "tray"
          ];
        };
      };
      style = ''
        * {
          border: none;
          border-radius: 0;
          font-family: "JetBrainsMono Nerd Font";
          font-size: 12px;
          min-height: 0;
        }

        window#waybar {
          background: rgba(21, 18, 27, 0.8);
          color: #cdd6f4;
        }

        #workspaces button {
          padding: 0 5px;
          background: transparent;
          color: #cdd6f4;
        }

        #workspaces button:hover {
          background: rgba(0, 0, 0, 0.2);
        }

        #workspaces button.active {
          background: #7aa2f7;
          color: #1e1e2e;
        }

        #clock,
        #battery,
        #cpu,
        #memory,
        #temperature,
        #network,
        #pulseaudio,
        #tray {
          padding: 0 10px;
          margin: 0 5px;
        }
      '';
    };
    
    home.packages = with pkgs; [
      waybar
    ];
  };
} 