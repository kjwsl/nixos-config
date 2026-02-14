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

    # Custom prefix (Ctrl-s instead of Ctrl-b)
    prefix = "C-s";

    # Additional configuration
    extraConfig = ''
      # Fix: Override HM's auto-generated default-command to use fish
      set -g default-command "${pkgs.fish}/bin/fish"

      # Unbind default prefix to prevent conflicts
      unbind C-b

      # Send prefix with prefix + a (like screen)
      bind a send-prefix

      # Improve paste time detection (prevents garbled SSH input)
      set -g assume-paste-time 1

      # Status bar position
      set-option -g status-position top

      # Better colors
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -ag terminal-overrides ",screen-256color:RGB"

      # Reload config easily
      unbind r
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "⚙️  Config reloaded"

      # Monitor activity in windows
      set -g monitor-activity on
      set -g visual-activity off

      # Better copy mode
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'C-v' send -X rectangle-toggle
      bind-key -T copy-mode-vi 'y' send -X copy-selection

      # Lock mode (like zellij) - Ctrl-s + Enter
      bind Enter \
        set prefix None \;\
        set key-table locked \;\
        set -g status-style "bg=#e74c3c,fg=#ffffff,bold" \;\
        set -g status-left "🔒 LOCKED " \;\
        set -g status-right " Press Ctrl-g to unlock 🔒" \;\
        set -g status-justify centre \;\
        refresh-client -S \;\
        display-message "🔒 LOCKED - Press Ctrl-g to unlock"

      bind -T locked C-g \
        set -u prefix \;\
        set -u key-table \;\
        set -ug status-style \;\
        set -ug status-left \;\
        set -ug status-right \;\
        set -ug status-justify \;\
        refresh-client -S \;\
        display-message "🔓 UNLOCKED"
    '';

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

      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }

      # Navigation
      pain-control
      vim-tmux-navigator
      yank

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
