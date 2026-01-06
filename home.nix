{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    bat
    btop
    cargo-watch
    chezmoi
    delta
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
    mise
    neovim
    nodejs_24
    nushell
    ripgrep
    rustup
    starship
    tmux
    tree
    yazi
    zig
    zoxide
  ];

  home.stateVersion = "25.05";
}
