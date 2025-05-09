{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.profiles.desktop-environments.hyprland;
in
{
  options.ray.home.profiles.desktop-environments.hyprland = {
    enable = mkEnableOption "Hyprland desktop environment";
  };

  config = mkIf cfg.enable {
    # Enable Hyprland
    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        # Monitor configuration
        monitor = [
          ",preferred,auto,1"
        ];

        # Input configuration
        input = {
          kb_layout = "us";
          follow_mouse = 1;
          touchpad = {
            natural_scroll = true;
            tap-to-click = true;
          };
          sensitivity = 0;
        };

        # General settings
        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          "col.active_border" = "rgba(7aa2f7aa)";
          "col.inactive_border" = "rgba(414868aa)";
          layout = "dwindle";
        };

        # Decoration settings
        decoration = {
          rounding = 10;
          blur = {
            enabled = true;
            size = 3;
            passes = 1;
          };
          drop_shadow = true;
          shadow_range = 4;
          shadow_render_power = 3;
          "col.shadow" = "rgba(1a1a1aee)";
        };

        # Animation settings
        animations = {
          enabled = true;
          bezier = "myBezier,0.05,0.9,0.1,1.05";
          animation = [
            "windows,1,7,myBezier"
            "windowsOut,1,7,default,popin 80%"
            "border,1,10,default"
            "borderangle,1,8,default"
            "fade,1,7,default"
            "workspaces,1,6,default"
          ];
        };

        # Layout settings
        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        # Master layout settings
        master = {
          new_is_master = true;
        };

        # Gestures
        gestures = {
          workspace_swipe = true;
          workspace_swipe_fingers = 3;
        };

        # Window rules
        windowrule = [
          "float,^(kitty)$"
          "float,^(pavucontrol)$"
          "float,^(blueman-manager)$"
          "float,^(nm-connection-editor)$"
        ];

        # Keybindings
        bind = [
          # Basic controls
          "SUPER,Return,exec,kitty"
          "SUPER,Q,killactive"
          "SUPER,M,exit"
          "SUPER,E,exec,dolphin"
          "SUPER,F,togglefloating"
          "SUPER,P,pseudo"
          "SUPER,J,togglesplit"

          # Window focus
          "SUPER,left,movefocus,l"
          "SUPER,right,movefocus,r"
          "SUPER,up,movefocus,u"
          "SUPER,down,movefocus,d"

          # Window movement
          "SUPERSHIFT,left,movewindow,l"
          "SUPERSHIFT,right,movewindow,r"
          "SUPERSHIFT,up,movewindow,u"
          "SUPERSHIFT,down,movewindow,d"

          # Workspace management
          "SUPER,1,workspace,1"
          "SUPER,2,workspace,2"
          "SUPER,3,workspace,3"
          "SUPER,4,workspace,4"
          "SUPER,5,workspace,5"
          "SUPER,6,workspace,6"
          "SUPER,7,workspace,7"
          "SUPER,8,workspace,8"
          "SUPER,9,workspace,9"
          "SUPER,0,workspace,10"

          # Move windows to workspaces
          "SUPERSHIFT,1,movetoworkspace,1"
          "SUPERSHIFT,2,movetoworkspace,2"
          "SUPERSHIFT,3,movetoworkspace,3"
          "SUPERSHIFT,4,movetoworkspace,4"
          "SUPERSHIFT,5,movetoworkspace,5"
          "SUPERSHIFT,6,movetoworkspace,6"
          "SUPERSHIFT,7,movetoworkspace,7"
          "SUPERSHIFT,8,movetoworkspace,8"
          "SUPERSHIFT,9,movetoworkspace,9"
          "SUPERSHIFT,0,movetoworkspace,10"

          # Special workspace
          "SUPER,Tab,workspace,previous"
          "SUPER,grave,workspace,e+1"
          "SUPERSHIFT,grave,movetoworkspace,e+1"

          # Media controls
          ",XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ",XF86AudioMute,exec,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ",XF86AudioPlay,exec,playerctl play-pause"
          ",XF86AudioNext,exec,playerctl next"
          ",XF86AudioPrev,exec,playerctl previous"

          # Screenshot
          ",Print,exec,grimblast copy area"
          "SHIFT,Print,exec,grimblast copy screen"
          "SUPER,Print,exec,grimblast save area"
          "SUPERSHIFT,Print,exec,grimblast save screen"
        ];

        # Mouse bindings
        bindm = [
          "SUPER,mouse:272,movewindow"
          "SUPER,mouse:273,resizewindow"
        ];
      };
    };

    # Enable required services
    services = {
      # Enable gammastep for night light
      gammastep = {
        enable = true;
        provider = "geoclue2";
      };

      # Enable network manager applet
      network-manager-applet.enable = true;

      # Enable blueman
      blueman-applet.enable = true;
    };

    # Enable required packages
    home.packages = with pkgs; [
      # Hyprland packages
      hyprland
      hyprpaper
      hyprpicker
      wl-clipboard
      wl-clip-persist
      wtype
      wl-clipboard-x11

      # Screenshot tools
      grimblast
      grim
      slurp

      # Audio control
      playerctl
      wireplumber

      # System utilities
      networkmanagerapplet
      blueman
      gammastep
      polkit_gnome
    ];

    # Enable required modules
    ray.home.modules = {
      apps = {
        waybar.enable = true;
        rofi.enable = true;
      };
    };
  };
} 