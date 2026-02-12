{ config, pkgs, lib, ... }:

{
  imports = [
    ./modules/shell.nix
    ./modules/starship.nix
    ./modules/git.nix
    ./modules/terminals.nix
    ./modules/multiplexers.nix
    ./modules/editors.nix
    ./modules/tools.nix
    ./modules/platforms.nix
    ./modules/dotfiles.nix
  ];

  # Only include packages that aren't managed by HM modules
  home.packages = with pkgs; [
    # CLI Tools (remove duplicates that are now managed by programs.*)
    amazon-q-cli
    # atuin  # managed by programs.atuin
    # bat    # managed by programs.bat
    bottom
    broot
    # btop   # managed by programs.btop
    cargo-watch
    chezmoi
    choose
    clang-tools
    cmake
    # delta  # managed by programs.git.delta
    difftastic
    dust
    eva
    # eza    # managed by programs.eza
    # fastfetch  # managed by programs.fastfetch
    fd
    # fish   # managed by programs.fish
    fselect
    # fzf    # managed by programs.fzf
    gcc
    # git    # managed by programs.git
    git-absorb
    gitoxide
    gitui
    glow
    gpg-tui
    hexyl
    httm
    hyperfine
    jujutsu
    just
    # lazygit  # managed by programs.lazygit
    lazyjj
    lemmeknow
    lsd
    mcfly
    mise
    navi
    neovim
    ninja
    nushell
    ouch
    procs
    repgrep
    ripgrep
    rm-improved
    rnr
    runiq
    ruplacer
    rust-parallel
    rustup
    scout
    sd
    silver-searcher
    skim
    so # Ask questions on StackOverflow
    # starship  # managed by programs.starship
    television
    tere
    tealdeer # tldr
    # tmux   # managed by programs.tmux
    tokei
    tre-command
    tree
    trippy
    uv
    vaultwarden
    xcp
    xh
    xxh
    # yazi   # managed by programs.yazi
    # zellij # managed by programs.zellij
    zig
    # zoxide # managed by programs.zoxide
  ];

  home.stateVersion = "25.05";
}