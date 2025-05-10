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
    jq      # Useful for JSON processing
    yq      # YAML processor
  ];
  
  # Shell configuration
  environment.shellInit = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';

  # Homebrew configuration 
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";  # More aggressive cleanup to keep system clean
    };
    taps = [
      "felixkratz/formulae"  # For sketchybar
      "koekeishiya/formulae" # For yabai if needed
    ];
    brews = [
      "sketchybar"          # Customizable menubar replacement
      "ifstat"              # Network monitoring for widgets
      "jq"                  # JSON processor for scripts
      "zoxide"             # Smarter cd command
      "eza"                # Modern ls replacement
    ];
    casks = [
      # Existing casks
      "krita"
      "librewolf"
      "alfred"
      "brave-browser"
      "cursor"
      
      # Tiling window manager
      "aerospace"           # Modern native tiling window manager
      
      # Widgets and utilities
      "ubersicht"           # Widget system for desktop customization
      "sf-symbols"          # Apple SF Symbols app (needed for icons)
      "stats"               # System monitoring in menubar
      "raycast"             # Better spotlight alternative
      
      # Visual enhancements
      "monitorcontrol"      # Control external display brightness/contrast
      "rectangle"           # Backup window management with mouse
      "alt-tab"             # Better Alt-Tab window switcher
      "iterm2"              # Terminal with better visual customization
      
      # Fonts for nice UI
      "font-jetbrains-mono-nerd-font"
      "font-hack-nerd-font"
      "font-fira-code"
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
      FXEnableExtensionChangeWarning = false;
      _FXShowPosixPathInTitle = true;
      QuitMenuItem = true; # Allow quitting finder
    };
    
    # Global settings
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";    # Dark mode
      AppleKeyboardUIMode = 3;         # Full keyboard control
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      "com.apple.swipescrolldirection" = true; # "Natural" scrolling on
    };
    
    # Better trackpad settings
    trackpad = {
      Clicking = true;              # Tap to click
      TrackpadRightClick = true;    # Two-finger right click
      TrackpadThreeFingerDrag = true; # Three finger dragging
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
    
    # Set up AeroSpace configuration
    if [ -d "/Applications/AeroSpace.app" ]; then
      echo "Configuring AeroSpace..."
      open -a AeroSpace
      sleep 2 # Give it time to start
      defaults write com.apple.AeroSpace autostart -bool true
      defaults write com.apple.AeroSpace default_padding 2
      defaults write com.apple.AeroSpace mouse_follows_focus -bool true
      defaults write com.apple.AeroSpace focus_follows_mouse -bool true
      
      # Load AeroSpace configuration
      echo "Make sure to add this to AeroSpace config: "
      echo "aerospace load-sa"
      
      # Restart AeroSpace after configuration
      killall AeroSpace || true
      open -a AeroSpace
    fi
    
    # Configure Ubersicht if installed
    if [ -d "/Applications/Übersicht.app" ]; then
      echo "Configuring Übersicht..."
      defaults write de.tracesof.uebersicht ZoomLevel 1.0
      defaults write de.tracesof.uebersicht VisibleInFullscreen -bool true
      defaults write de.tracesof.uebersicht OpenAtLogin -bool true
      
      # Start Ubersicht
      open -a "Übersicht"
    fi
  '';
  
  # System version
  system.stateVersion = 5;
}
