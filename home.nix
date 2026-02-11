{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    bat
    btop
    cargo-watch
    chezmoi
    clang-tools
    cmake
    delta
    difftastic
    eza
    fastfetch
    fd
    fish
    fzf
    gcc
    git
    glow
    jujutsu
    just
    lazygit
    lazyjj
    mise
    neovim
    so # Ask questions on StackOverflow https://github.com/samtay/so
    ninja
    nushell
    ripgrep
    rustup
    silver-searcher
    starship
    tldr
    tmux
    tre-command
    tree
    uv
    yazi
    zellij
    zig
    zoxide
  ];

  home.stateVersion = "25.05";
}
