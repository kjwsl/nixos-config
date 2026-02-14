# Development profile - Full dev environment
{ config, pkgs, ... }:

{
  imports = [
    ./base.nix
    ../modules/editors.nix
    ../modules/multiplexers.nix
    ../modules/terminals.nix
    ../modules/tools.nix
    ../modules/privacy.nix
  ];

  # Enable privacy tools (opt-in, disabled by default)
  services.privacy = {
    enable = false;  # Set to true to enable i2p/v2ray

    i2p = {
      enable = false;  # Uncomment and set true to enable
    };

    v2ray = {
      enable = false;  # Uncomment and set true to enable
      useV2RayA = true;  # Use GUI version
    };
  };

  # Development-specific packages
  home.packages = with pkgs; [
    # Development tools
    clang-tools
    cmake
    gcc
    ninja
    rustup
    mise

    # Version control
    lazygit
    gitui
    gitoxide
    lazyjj

    # Productivity
    hyperfine
    tokei
    dust

    # Languages & runtimes
    uv  # Python
    zig

    # All your current tools
    amazon-q-cli
    bottom
    cargo-watch
    chezmoi
    choose
    difftastic
    eva
    fastfetch
    fselect
    glow
    gpg-tui
    hexyl
    httm
    just
    lemmeknow
    lsd
    mcfly
    navi
    ouch
    procs
    repgrep
    rm-improved
    rnr
    runiq
    ruplacer
    rust-parallel
    scout
    sd
    silver-searcher
    skim
    so
    television
    tere
    tealdeer
    tre-command
    trippy
    vaultwarden
    xcp
    xh
    xxh
  ];

  # Development-specific fish config
  programs.fish.shellAliases = {
    # Development shortcuts
    gs = "git status";
    gd = "git diff";
    gl = "git log --oneline --graph";
    dc = "docker compose";
  };
}
