# Base package set for all platforms.
# Contributes to flake.modules.homeManager.base.
{inputs, ...}: {
  flake.modules.homeManager.base = {pkgs, ...}: let
    hostSystem = pkgs.stdenv.hostPlatform.system;
  in {
    home.packages = with pkgs; [
      _7zz-rar
      age
      alejandra
      amazon-q-cli
      ast-grep
      bat
      bitwarden-cli
      gnumake
      cmake
      ninja
      unzip
      cachix
      cargo-binstall
      cargo-watch
      chezmoi
      choose
      clang-tools
      cmake
      delta
      difftastic
      dotter # dotfile manager
      duf # Disk Usage/Free Utility
      dust
      eva
      fastfetch
      fd
      fish-lsp
      mkcert # Simple tool to make locally trusted development certificates
      fselect
      fzf
      gcc
      ripdrag # Drag and drop files into the terminal
      gh
      git
      git-absorb
      gitoxide
      gitui
      glow
      gpg-tui
      hexyl
      httm
      hyperfine
      just
      lazygit
      lazyjj
      lemmeknow
      lsd
      mcfly
      mprocs
      navi
      nb # local web note‑taking, bookmarking, archiving, and knowledge base
      neovim
      nh
      nil
      ninja
      nufmt # Nushell Formatter
      openssh
      ouch
      procs
      ripgrep
      ripgrep-all
      rm-improved
      rnr
      runiq # Efficient way to filter duplicate lines from input, à la uniq
      ruplacer # Find and replace text in source files
      rust-parallel
      rust-script
      rustup
      scout
      sd # Intuitive find & replace CLI (sed alternative)
      sops
      ssh-to-age
      tealdeer
      tere
      tmux
      tokei
      tre-command
      tree
      trippy
      vaultwarden
      wakatime-cli
      xcp
      xh
      xxh
      zig
      zmate # Instant terminal sharing using Zellij

      # Fonts
      nerd-fonts.jetbrains-mono

    ];
  };
}
