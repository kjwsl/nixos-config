{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    # frawk
    # termscp
    #loop
    amazon-q-cli
    atuin
    mprocs # Run multiple processes in parallel
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
    nh
    ninja
    ouch
    procs
    ripgrep
    ripgrep-all
    rm-improved # Remove files with confirmation
    rnr # Rename files with confirmation
    runiq # Remove duplicate lines
    ruplacer
    rust-parallel
    rustup
    scout # URL fuzzy finder
    sd
    silver-searcher # Fuzzy finder
    skim # Fuzzy finder
    so # Ask questions on StackOverflow https://github.com/samtay/so
    tealdeer # tldr tlrc
    tere
    tmux
    tokei # Count your code with extra features like language support
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

  home.shell.enableNushellIntegration = true;

  programs = {
    direnv = {
      enable = true;

      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;

      mise.enable = true;
    };

    television = {
      enable = true;

      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };

    nix-search-tv.enableTelevisionIntegration = true;

    zoxide = {
      enable = true;

      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;

    };
    nushell = { 
      enable = true;
      shellAliases = {
        v = "nvim";
      };
      plugins = with pkgs.nushellPlugins; [
        formats
      ];
   };  

   carapace.enable = true;
   carapace.enableNushellIntegration = true;

   starship = { 
     enable = true;
       settings = {
         add_newline = true;
         character = { 
         success_symbol = "[➜](bold green)";
         error_symbol = "[➜](bold red)";
         };
      };

      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;

      enableTransience = true;

    };
  };

  home.stateVersion = "25.05";
}
