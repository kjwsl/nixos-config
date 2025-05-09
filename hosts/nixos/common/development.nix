{ config, pkgs, ... }:

{
  # Development tools
  environment.systemPackages = with pkgs; [
    # Version control
    git
    git-lfs
    lazygit
    github-cli

    # Editors
    vim
    neovim
    code-cursor

    # Programming languages
    python3Full
    rustup
    nodejs
    go

    # Build tools
    gcc
    gnumake
    cmake
    ninja
    pkg-config

    # Development utilities
    fzf
    zoxide
    tmux
    wezterm
    kitty
    ripgrep
    fd
    bat
    eza
    jq
    yq-go
    docker
    docker-compose
  ];

  # Enable Docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # Enable development shells
  programs = {
    # Enable direnv
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # Enable git
    git = {
      enable = true;
      config = {
        init.defaultBranch = "main";
        user.name = "ray";
        user.email = "ray@example.com";
      };
    };
  };
} 