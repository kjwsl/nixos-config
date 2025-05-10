{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.profiles;
in
{
  options.ray.home.profiles = {
    active = mkOption {
      type = types.enum [ "desktop" "development" "work" ];
      default = "desktop";
      description = "The active profile to use";
    };
    
    desktopEnvironment = mkOption {
      type = types.enum [ "hyprland" "gnome" ];
      default = "gnome";
      description = "The active desktop environment to use";
    };
  };

  # Instead of importing, just configure directly based on the profile
  config = mkMerge [
    # Desktop profile
    (mkIf (cfg.active == "desktop") {
      ray.home.modules = mkMerge [
        {
          apps = {
            wezterm.enable = true;
            kitty.enable = true;
          };
          shell = {
            fish.enable = true;
            zoxide.enable = true;
            bat.enable = true;
            eza.enable = true;
          };
        }
        (mkIf pkgs.stdenv.isLinux {
          apps = {
            rofi.enable = true;
            waybar.enable = true;
            discord.enable = true;
            telegram.enable = true;
            steam.enable = true;
            qbittorrent.enable = true;
          };
        })
      ];
    })
    
    # Development profile
    (mkIf (cfg.active == "development") {
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
    })
    
    # Work profile
    (mkIf (cfg.active == "work") {
      ray.home.modules = {
        apps = {
          wezterm.enable = true;
          kitty.enable = true;
          neovim.enable = true;
          telegram.enable = true;
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
          nodejs.enable = true;
          pyenv.enable = true;
        };
      };
    })
    
    # Hyprland desktop environment
    (mkIf (cfg.desktopEnvironment == "hyprland" && pkgs.stdenv.isLinux) {
      home.packages = with pkgs; [
        hyprland
        waybar
        wofi
        swww
        dunst
        libnotify
        wl-clipboard
        grim
        slurp
      ];
    })
    
    # GNOME desktop environment
    (mkIf (cfg.desktopEnvironment == "gnome" && pkgs.stdenv.isLinux) {
      home.packages = with pkgs; [
        gnome-tweaks
        dconf-editor
        gnome-extension-manager
        gnomeExtensions.dash-to-dock
        gnomeExtensions.appindicator
        gnomeExtensions.blur-my-shell
        gnomeExtensions.clipboard-indicator
      ];
    })
  ];
}
