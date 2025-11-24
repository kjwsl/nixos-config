{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    bat
    cargo-watch
    chezmoi
    delta
    eza
    fastfetch
    fd
    fish
    fzf
    git
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
    zoxide
  ];

  home.stateVersion = "25.05";
}
