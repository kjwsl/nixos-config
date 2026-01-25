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
    lazygit
    lazyjj
    mise
    neovim
    ninja
    nodejs_24
    nushell
    ripgrep
    rustup
    starship
    tmux
    tree
    uv
    yazi
    zellij
    zig
    zoxide
  ];

  home.stateVersion = "25.05";
}
