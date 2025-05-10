{ config, pkgs, system, ... }:

{
  # User settings
  users.users.ray.home = /Users/ray;
  
  # Package configuration
  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "aarch64-darwin";
  };
  
  # Basic system packages
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
  ];
  
  # Shell configuration
  environment.shellInit = ''
    "eval "$(/opt/homebrew/bin/brew shellenv)""
  '';

  # Homebrew configuration 
  homebrew = {
    enable = true;
    casks = [
      "krita"
      "librewolf"
      "alfred"
    ];
  };

  # Homebrew installation
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
  
  # Program configuration
  programs = {
    gnupg.agent.enable = true;
    zsh = {
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

  # macOS-specific system defaults
  system.defaults = {
    # Dock configuration
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
    
    # Finder configuration
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
    };
  };

  # Security configuration
  security.pam.services.sudo_local.touchIdAuth = true;

  # Nix configuration
  nix = {
    package = pkgs.nix;
    settings = {
      "extra-experimental-features" = [ "nix-command" "flakes" ];
    };
  };
  
  # Custom activation script to reset the Dock
  system.activationScripts.postUserActivation.text = ''
    # Restart the Dock completely
    echo "Resetting the Dock..."
    killall Dock || true
  '';
  
  # System version
  system.stateVersion = 5;
}
