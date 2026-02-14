{ config, pkgs, ... }:

let
  # tmux-powerkit - The Ultimate tmux Status Bar Framework
  # 42 production-ready plugins, 37 themes, 61 variants
  # REQUIRES: Bash 5.1+ (macOS ships with 3.2, so we patch it)
  tmux-powerkit = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-powerkit";
    version = "unstable-2026-02-14";
    src = pkgs.fetchFromGitHub {
      owner = "fabioluciano";
      repo = "tmux-powerkit";
      rev = "ccd1c5269964b37c0aab0b284e834c53730c9e4b";  # Latest commit
      sha256 = "sha256-zj0jymsNfTifXsSsxcPo4MIAI5o+WAkAXSdPl988BcM=";
    };
    rtpFilePath = "tmux-powerkit.tmux";

    # Patch shebang to use Nix-provided bash 5.x
    postInstall = ''
      substituteInPlace $target/tmux-powerkit.tmux \
        --replace '#!/usr/bin/env bash' '#!${pkgs.bash}/bin/bash'
    '';

    nativeBuildInputs = [ pkgs.bash ];
  };
in
{
  # Tmux - Terminal multiplexer (Nixified configuration)
  programs.tmux = {
    enable = true;

    # Default shell
    shell = "${pkgs.fish}/bin/fish";

    # Terminal settings
    terminal = "tmux-256color";
    baseIndex = 1;
    escapeTime = 10;  # Fast escape for Neovim
    historyLimit = 50000;

    # Mouse support
    mouse = true;

    # Enable focus events for better terminal integration
    focusEvents = true;

    # Use vi keybindings
    keyMode = "vi";

    # Custom prefix (Ctrl-a instead of Ctrl-b)
    prefix = "C-a";

    # Plugins (Nix-managed, no TPM needed!)
    plugins = with pkgs.tmuxPlugins; [
      # Essential functionality
      sensible

      # Session persistence
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-strategy-nvim 'session'
        '';
      }

      # Navigation
      pain-control
      vim-tmux-navigator
      yank
      tmux-thumbs

      copycat
      cpu
      battery
      prefix-highlight
      sidebar

      # tmux-powerkit - The Ultimate Status Bar Framework
      # Includes 42 plugins, 37 themes with 61 variants, smart caching
      {
        plugin = tmux-powerkit;
        extraConfig = ''
          # Enable powerkit
          set -g @powerkit-enabled true

          # Choose theme (default is 'default', other options in repo)
          # Available: default, nord, dracula, gruvbox, catppuccin, etc.
          set -g @powerkit-theme 'catppuccin'

          # Status bar position
          set -g @powerkit-status-position 'top'

          # Enable plugins you want
          set -g @powerkit-plugins 'cpu battery time hostname'
        '';
      }
    ];
  };

  # Zellij - Modern terminal multiplexer (kept for comparison)
  programs.zellij = {
    enable = true;
    enableFishIntegration = false;

    settings = {
      theme = "catppuccin-mocha";
      pane_frames = true;
      simplified_ui = false;
      default_shell = "fish";
      copy_command = "pbcopy";
      copy_on_select = true;
      mouse_mode = true;
      scroll_buffer_size = 10000;
    };
  };
}
