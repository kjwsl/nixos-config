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
    yazi
    zoxide
  ];

  home.stateVersion = "25.05";
}
