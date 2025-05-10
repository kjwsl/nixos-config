{ config, pkgs, system, ... }:

{
  users.users.ray.home = /Users/ray;
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
  ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";
  
  # Overlays to handle problematic packages
  nixpkgs.overlays = [
    (final: prev: {
      # Provide empty/stub packages for Linux-only applications on Darwin
      rofi = if pkgs.stdenv.isDarwin then prev.runCommandNoCC "rofi-stub" {} "mkdir -p $out" else prev.rofi;
      waybar = if pkgs.stdenv.isDarwin then prev.runCommandNoCC "waybar-stub" {} "mkdir -p $out" else prev.waybar;
      discord = if pkgs.stdenv.isDarwin then prev.runCommandNoCC "discord-stub" {} "mkdir -p $out" else prev.discord;
      telegram-desktop = if pkgs.stdenv.isDarwin then prev.runCommandNoCC "telegram-desktop-stub" {} "mkdir -p $out" else prev.telegram-desktop;
      steam = if pkgs.stdenv.isDarwin then prev.runCommandNoCC "steam-stub" {} "mkdir -p $out" else prev.steam;
      steam-run = if pkgs.stdenv.isDarwin then prev.runCommandNoCC "steam-run-stub" {} "mkdir -p $out" else prev.steam-run;
      qbittorrent = if pkgs.stdenv.isDarwin then prev.runCommandNoCC "qbittorrent-stub" {} "mkdir -p $out" else prev.qbittorrent;
      gnome-tweaks = if pkgs.stdenv.isDarwin then prev.runCommandNoCC "gnome-tweaks-stub" {} "mkdir -p $out" else prev.gnome-tweaks;
      
      # Handle any other Linux-only dependencies
      rofi-calc = if pkgs.stdenv.isDarwin then prev.runCommandNoCC "rofi-calc-stub" {} "mkdir -p $out" else prev.rofi-calc;
      rofi-emoji = if pkgs.stdenv.isDarwin then prev.runCommandNoCC "rofi-emoji-stub" {} "mkdir -p $out" else prev.rofi-emoji;
      rofi-power-menu = if pkgs.stdenv.isDarwin then prev.runCommandNoCC "rofi-power-menu-stub" {} "mkdir -p $out" else prev.rofi-power-menu;
    })
  ];
  
  environment.shellInit = ''
    "eval "$(/opt/homebrew/bin/brew shellenv)""
  '';

  system.activationScripts.installHomebrew = {
    text = ''
      if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo "Adding Homebrew to PATH..."
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi
    '';
  };
  programs = {
    gnupg.agent.enable = true;
    zsh =
      {
        enable = true;
        shellInit = ''
          eval "$(/opt/homebrew/bin/brew shellenv)"
        '';
      };
    man.enable = true;
    tmux = {
      enable = true;
      enableFzf = true;
      enableVim = true;
    };
  };

  system.defaults = {
    dock = {
      autohide = true;
      orientation = "bottom";
      showhidden = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.5;
      expose-animation-duration = 0.1;
      tilesize = 48;
      mineffect = "scale";
      launchanim = true;
      static-only = false;
      show-recents = false;
      show-process-indicators = true;
      mouse-over-hilite-stack = true;
    };
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
    };
  };

  # Updated TouchID configuration
  security.pam.services.sudo_local.touchIdAuth = true;

  # Auto upgrade nix packages and the demon service.
  homebrew = {
    enable = true;
    casks = [
      "krita"
      "librewolf"
      "alfred"
    ];
  };

  nix = {
    package = pkgs.nix;
    settings = {
      "extra-experimental-features" = [ "nix-command" "flakes" ];
    };
  };
  system.stateVersion = 5;

  # Add a separate activation script to fully reset the Dock
  system.activationScripts.postUserActivation.text = ''
    # Restart the Dock completely
    echo "Resetting the Dock..."
    killall Dock || true
  '';
}
