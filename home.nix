{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    bat
    cargo-watch
    chezmoi
    delta
    eza
    fastfetch
    fd
    fish # Added fish to packages
    fzf
    git
    lazygit
    mise
    neovim
    nodejs_24
    ripgrep
    rustup
    tmux
    tree
    zoxide
  ];

  home.stateVersion = "25.05";
}
