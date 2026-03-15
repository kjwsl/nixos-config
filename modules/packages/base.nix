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

      # LLM Agents
      inputs.llm-agents.packages.${hostSystem}.claude-code
      inputs.llm-agents.packages.${hostSystem}.gemini-cli
      inputs.llm-agents.packages.${hostSystem}.goose-cli
      inputs.llm-agents.packages.${hostSystem}.code
      inputs.llm-agents.packages.${hostSystem}.opencode
      inputs.llm-agents.packages.${hostSystem}.crush
      inputs.llm-agents.packages.${hostSystem}.pi
      inputs.llm-agents.packages.${hostSystem}.ck
      inputs.llm-agents.packages.${hostSystem}.gno
      inputs.llm-agents.packages.${hostSystem}.beads
      inputs.llm-agents.packages.${hostSystem}.beads-viewer
      inputs.llm-agents.packages.${hostSystem}.tuicr
      inputs.llm-agents.packages.${hostSystem}.rtk
      inputs.llm-agents.packages.${hostSystem}.ccusage
      inputs.llm-agents.packages.${hostSystem}.ccusage-opencode
      inputs.llm-agents.packages.${hostSystem}.mcporter
      inputs.llm-agents.packages.${hostSystem}.happy-coder
      inputs.llm-agents.packages.${hostSystem}.openskills
      inputs.llm-agents.packages.${hostSystem}.handy
      inputs.llm-agents.packages.${hostSystem}.entire
      inputs.llm-agents.packages.${hostSystem}.agent-browser
      inputs.llm-agents.packages.${hostSystem}.jules
    ];
  };
}
