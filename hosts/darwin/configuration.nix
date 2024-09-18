{ config, pkgs, username, system, ... }:

{
  users.users.ray.home = /Users/ray;
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    librewolf-unwrapped
  ];
  nixpkgs.config.allowUnfree = true;

  programs = {
    man.enable = true;
    tmux = {
      enable = true;
      enableFzf = true;
      enableVim = true;
    };
  };

  system.defaults.dock = {
    autohide = true;
    orientation = "bottom";
    showhidden = true;
  };
  security.pam.enableSudoTouchIdAuth = true;

  # Auto upgrade nix packages and the demon service.
  services.nix-daemon.enable = true;
  homebrew = {
    enable = true;
    casks = [
      "krita"
      "firefox"
      "librewolf"
    ];
  };
  system.stateVersion = 5;
}
