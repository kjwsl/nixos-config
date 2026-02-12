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
    # CLI Tools (removed duplicates now managed by programs.*)
    amazon-q-cli
    # atuin        # managed by programs.atuin (advanced config)
    # bat          # managed by programs.bat (catppuccin theme)
    # btop         # managed by programs.btop via shell.nix (advanced config)
    # broot        # managed by programs.broot (advanced config)
    cargo-watch
    chezmoi
    choose
    clang-tools
    cmake
    # delta        # managed by programs.git.delta
    difftastic
    dust
    duf             # Modern df alternative
    eva
    # eza          # managed by programs.eza (advanced config)
    # fastfetch    # managed by shell.nix with custom config
    fd
    # fish         # managed by programs.fish (comprehensive config)
    fselect
    # fzf          # managed by programs.fzf (catppuccin + advanced)
    gcc
    # git          # managed by programs.git (comprehensive)
    git-absorb
    gitoxide
    gitui
    glow
    gpg-tui
    hexyl
    httm
    hyperfine
    jq              # JSON processor
    jujutsu
    just
    # lazygit      # managed by programs.lazygit (catppuccin theme)
    lazyjj
    lemmeknow
    lsd
    # mcfly        # handled in fish init
    miller          # CSV/JSON processor
    mise
    # navi         # CLI cheatsheet (keeping as package)
    navi
    neovim
    ninja
    # nushell      # managed by programs.nushell (advanced config)
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
    so              # Ask questions on StackOverflow
    # starship     # managed by programs.starship (comprehensive theme)
    television
    tere
    tealdeer        # tldr
    tig             # Git repository browser
    # tmux         # managed by programs.tmux (power-user config)
    tokei
    tre-command
    tree
    trippy
    uv
    vaultwarden
    xcp
    xh
    xxh
    # yazi         # managed by programs.yazi (advanced config)
    # zellij       # managed by programs.zellij
    zig
    # zoxide       # managed by programs.zoxide
    
    # Additional power-user tools
    slides          # Terminal slideshow tool
    gum             # Shell script UI toolkit
    charm           # Charm CLI tools
    fx              # JSON viewer/processor
    viddy           # Modern watch command
    dog             # DNS lookup tool
    grex            # Generate regex from examples
    tokei           # Code statistics
    bandwhich       # Network utilization by process
    zenith          # System monitor
    
    # Development tools not covered by modules
    dive            # Docker image analyzer
    ctop            # Container top
    lazydocker      # Docker TUI
    
    # System utilities
    pstree          # Process tree
    lnav            # Log file navigator
    nq              # Job queue
    
    # File processing
    jless           # JSON pager
    visidata        # Terminal spreadsheet
    
    # Network tools
    curlie          # Curl with httpie syntax
    httpie          # HTTP client
    websocat        # WebSocket client
  ];

  # Global environment variables for power users
  home.sessionVariables = {
    # Development
    RUST_LOG = "warn";
    CARGO_TERM_COLOR = "always";
    FORCE_COLOR = "1";
    CLICOLOR_FORCE = "1";
    
    # Better defaults
    LESSHISTFILE = "-";
    LESS = "-R";
    
    # Tool configurations
    # FZF_DEFAULT_OPTS is handled by programs.fzf.defaultOptions
    RIPGREP_CONFIG_PATH = "$HOME/.config/ripgrep/ripgreprc";
    BAT_THEME = "Catppuccin-mocha";
    
    # XDG directories
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_STATE_HOME = "$HOME/.local/state";
  };
  
  # Enable fontconfig for better terminal font rendering
  fonts.fontconfig.enable = true;

  home.stateVersion = "25.05";
}