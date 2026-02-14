{ config, pkgs, ... }: {
  imports = [
    ./modules/shell.nix
    ./modules/starship.nix
    ./modules/git.nix
    ./modules/editors.nix
    ./modules/multiplexers.nix
    ./modules/terminals.nix
    ./modules/tools.nix
    ./modules/privacy.nix
    ./modules/himalaya.nix
    # ./modules/dotfiles.nix  # Removed - configs migrated to proper modules
  ];

  home.packages = (with pkgs; [
    # Tools managed via native HM modules have been moved to:
    # - modules/shell.nix: fish, zoxide, fzf, atuin
    # - modules/starship.nix: starship
    # - modules/git.nix: git, delta, lazygit
    # - modules/editors.nix: neovim
    # - modules/multiplexers.nix: tmux, zellij
    # - modules/tools.nix: bat, eza, yazi, btop, broot, nushell

    # System essentials
    bash  # Bash 5.x required for tmux-powerkit (macOS ships with 3.2)
    nh    # Modern Nix helper - unified CLI for home-manager/darwin/nixos

    # frawk
    #loop
    amazon-q-cli
    bottom
    cargo-watch
    chezmoi
    choose
    clang-tools
    cmake
    difftastic
    dust
    eva
    fastfetch
    fd
    fselect
    gcc
    git-absorb
    gitoxide
    gitui
    glow
    gpg-tui
    hexyl
    httm
    hyperfine
    jujutsu
    jj-starship  # Starship integration for Jujutsu
    just
    lazyjj
    lemmeknow
    lsd
    mcfly
    mise
    navi
    ninja
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
    television
    tere
    # termscp
    tealdeer # tldr tlrc
    tokei
    tre-command
    tree
    trippy
    uv
    vaultwarden
    xcp
    xh
    xxh
    zig
  ]);

  # Enable Himalaya email client with Fish shortcuts
  programs.himalaya-custom.enable = true;

  # Allow overwriting existing config files
  xdg.configFile."zellij/config.kdl".force = true;

  home.stateVersion = "25.05";
}
