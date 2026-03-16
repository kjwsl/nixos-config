{ config, lib, pkgs, ... }:

{
  # Simply install just the packages
  environment.packages = with pkgs; [
    # User-facing stuff that you really really want to have
    vim # or some other editor, e.g. nano or neovim

    # Some common stuff that people expect to have
    #procps
    killall
    diffutils
    findutils
    util-linux
    tzdata
    hostname
    man
    gnugrep
    gnupg
    gnused
    gnutar
    bzip2
    gzip
    xz
    zip
    unzip
    less
    curl
    wget
    bun
    git
    lazygit
    mise
    which
    nushell
    zellij
    sudo
    chezmoi
    fish
    neovim
    nb
    zoxide
    fzf
    ripgrep
    fd
    btop
    rustup
    direnv
    gcc
    yazi
    evil-helix
    starship
    bat
    btop
    uv
    openssh
    nodejs
    bun
    pkg-config
    jujutsu
    cargo-binstall
    nerd-fonts.jetbrains-mono
  ];

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "24.05";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  android-integration = {
    am.enable = true;
    termux-open.enable = true;
    termux-reload-settings.enable = true;
    termux-setup-storage.enable = true;
    xdg-open.enable = true;
  };

  # user.shell = "${lib.getExe pkgs.fish}";
  user.shell = "${pkgs.bash}/bin/bash";
  
  time.timeZone = "Asia/Seoul";

  # Set your time zone
  #time.timeZone = "Europe/Berlin";
}
