{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    # frawk
    # termscp
    #loop
    amazon-q-cli
    atuin
    bat
    bitwarden-cli
    bottom
    broot
    btop
    cargo-watch
    chezmoi
    choose
    clang-tools
    cmake
    delta
    difftastic
    dust
    eva
    eza
    fastfetch
    fd
    fish
    fselect
    fzf
    gcc
    git
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
    lazygit
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
    so # Ask questions on StackOverflow https://github.com/samtay/so
    starship
    tealdeer # tldr tlrc
    television
    tere
    tmux
    tokei
    tre-command
    tree
    trippy
    uv
    vaultwarden
    xcp
    xh
    xxh
    yazi
    zellij
    zig
    zoxide
  ];

  home.stateVersion = "25.05";
}
