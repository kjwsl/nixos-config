{
  config,
  lib,
  pkgs,
  catppuccin,
  ...
}:
let
  isDarwin = lib.darwin.isDarwin;
in
{
  home.packages = with pkgs; [
    # frawk
    # termscp
    #loop
    alejandra # Nix code formatter
    amazon-q-cli
    atuin
    bat
    bitwarden-cli
    bottom
    broot
    btop
    cachix
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
    gh
    starship
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
    mprocs # Run multiple processes in parallel
    navi
    neovim
    nh
    nil # Nix LSP
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

    # Python Tool Suite
    uv

    vaultwarden

    xcp
    xh
    xxh

    # File Explorer
    yazi

    # Terminal Multiplexer
    zellij
    zig
    zoxide
  ];

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

      extraConfig = ''
        # Add nix profile to PATH
                    $env.PATH ++= [ "~/.nix-profile/bin" ]
      '';

      shellAliases = {
        "v." = "nvim .";
        v = "nvim";
      };

      plugins = with pkgs.nushellPlugins; [
        formats
        skim
        semver
        highlight
        gstat
        query
      ];
    };

    carapace = {
      enable = true;

      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };

    # Custom Prompt
    # starship = {
    #   enable = true;
    #   settings = {
    #     add_newline = true;
    #     character = {
    #       success_symbol = "[➜](bold green)";
    #       error_symbol = "[➜](bold red)";
    #     };
    #   };

    #   enableBashIntegration = true;
    #   enableZshIntegration = true;
    #   enableFishIntegration = true;
    #   enableNushellIntegration = true;
    #
    #   enableTransience = true;
    # };

    #   vivid = {
    #     enable = true;
    #     themes = {
    #       mocha = builtins.fetchurl {
    #         url = "https://raw.githubusercontent.com/NearlyTRex/Vivid/refs/heads/master/themes/catppuccin-mocha.yml";
    #         sha256 = "sha256:1hfwaf8lfq32w9vcdlbwrq5hwwz725i7icavg6qs66awpzqqb34k";
    #       };
    #     };
    #
    #     activeTheme = "mocha";
    #
    #     enableBashIntegration = true;
    #     enableZshIntegration = true;
    #     enableFishIntegration = true;
    #     enableNushellIntegration = true;
    #   };
    # };
    # };
  };

  catppuccin = {
    enable = true;
    flavor = "mocha";

    atuin.enable = true;
    bat.enable = true;
    bottom.enable = true;
    broot.enable = true;
    btop.enable = true;
    delta.enable = true;
    eza.enable = true;
    fish.enable = true;
    fzf.enable = true;
    gemini-cli.enable = true;
    ghostty.enable = true;
    helix.enable = true;
    nushell.enable = true;
    skim.enable = true;
    starship.enable = true;
    lazygit.enable = true;
    lsd.enable = true;
    television.enable = true;
    thunderbird.enable = true;
    yazi.enable = true;
    zed.enable = true;
    zellij.enable = true;
  };

  home.stateVersion = "25.05";
}
