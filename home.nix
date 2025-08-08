{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    bat
    cargo-watch
    eza
    fastfetch
    fd
    fzf
    git
    neovim
    ripgrep
    rustup
    tree
    zoxide
  ];

  home.stateVersion = "25.05";
}
