# Base package set for all platforms.
# Contributes to flake.modules.homeManager.base.
{...}: {
  flake.modules.homeManager.base = {pkgs, ...}: {
    home.packages = with pkgs; [
      _7zz-rar
      age
      alejandra
      amazon-q-cli
      ast-grep
      bat
      bitwarden-cli
      broot
      btop
      cachix
      cargo-binstall
      cargo-watch
      chezmoi
      choose
      clang-tools
      cmake
      delta
      difftastic
      duf # Disk Usage/Free Utility
      dust
      eva
      eza
      fastfetch
      fd
      fselect
      fzf
      gcc
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
    ];
  };
}
