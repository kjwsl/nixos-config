{ config, pkgs, username, system, ... }:

{
  users.users.ray.home = /Users/ray;
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
  ];
  nixpkgs.config.allowUnfree = true;
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
    zsh.enable = true;
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
    };
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
    };
  };
  security.pam.enableSudoTouchIdAuth = true;

  # Auto upgrade nix packages and the demon service.
  homebrew = {
    enable = true;
    casks = [
      "krita"
      "firefox"
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
  services.nix-daemon.enable = true;
  system.stateVersion = 5;
}
