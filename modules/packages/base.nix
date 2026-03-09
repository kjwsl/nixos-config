# Base package set for all platforms.
# Contributes to flake.modules.homeManager.base.
{...}: {
  flake.modules.homeManager.base = {pkgs, ...}: {
    home.packages = with pkgs; [
      alejandra
      ast-grep
      amazon-q-cli
      bat
      bitwarden-cli
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
      neovim
      nh
      nil
      ninja
      openssh
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
      tealdeer
      tere
      tmux
      tokei
      tre-command
      tree
      trippy
      vaultwarden
      xcp
      xh
      xxh
      zellij
      zig
      _7zz-rar
      ouch
    ];
  };
}
