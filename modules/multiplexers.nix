{ config, pkgs, lib, ... }:

{
  programs.tmux = {
    enable = true;
    clock24 = true;
    escapeTime = 10;  # Fix terminal responsiveness 
    historyLimit = 10000;
    keyMode = "vi";
    prefix = "C-s";    # Change prefix from default C-b to C-s
    mouse = true;
    sensibleOnTop = true;
    terminal = "tmux-256color";
    
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = tmux-nova;
        extraConfig = ''
          # tmux-nova configuration (Catppuccin Mocha)
          set -g @nova-nerdfonts true
          set -g @nova-nerdfonts-left 
          set -g @nova-nerdfonts-right 
          
          # Color palette (Catppuccin Mocha)
          set -g @nova-pane-active-border-style "#89b4fa"
          set -g @nova-pane-border-style "#45475a"
          set -g @nova-status-style-bg "#1e1e2e"
          set -g @nova-status-style-fg "#cdd6f4"
          set -g @nova-status-style-active-bg "#89b4fa"
          set -g @nova-status-style-active-fg "#1e1e2e"
          
          # Segment: Mode indicators (left side)
          set -g @nova-segment-mode "#{?client_prefix,⌨️  PREFIX,#{?pane_in_mode,📋 COPY,#{?pane_synchronized,🔄 SYNC,#{?window_zoomed_flag,🔍 ZOOM,}}}}"
          set -g @nova-segment-mode-colors "#fab387 #1e1e2e"
          
          # Segment: Session name
          set -g @nova-segment-session " #S"
          set -g @nova-segment-session-colors "#a6e3a1 #1e1e2e"
          
          # Segment: CPU usage
          set -g @nova-segment-cpu " #{cpu_percentage}"
          set -g @nova-segment-cpu-colors "#f9e2af #1e1e2e"
          
          # Segment: Battery
          set -g @nova-segment-battery "#{battery_icon} #{battery_percentage}"
          set -g @nova-segment-battery-colors "#f38ba8 #1e1e2e"
          
          # Segment: Uptime
          set -g @nova-segment-uptime " #{uptime}"
          set -g @nova-segment-uptime-colors "#b4befe #1e1e2e"
          
          # Segment: User and host
          set -g @nova-segment-whoami "#(whoami)@#h"
          set -g @nova-segment-whoami-colors "#89b4fa #1e1e2e"
          
          # Pane format
          set -g @nova-pane "#I#{?pane_in_mode,  #{pane_mode},}  #W"
          set -g @nova-pane-justify "left"
          
          # Status bar layout
          set -g @nova-rows 0
          set -g @nova-segments-0-left "mode"
          set -g @nova-segments-0-right "cpu battery session whoami"
        '';
      }
      better-mouse-mode
      battery
      continuum
      cpu
      logging
      open
      pain-control
      resurrect
      yank
      {
        plugin = tmux-fzf;
        extraConfig = ''
          set -g @tmux-fzf-launch-key "C-f"
          bind-key "f" run-shell -b "~/.config/tmux/plugins/tmux-fzf/scripts/session.sh switch"
        '';
      }
      {
        plugin = prefix-highlight;
        extraConfig = ''
          set -g status-position top
        '';
      }
    ];
    
    extraConfig = ''
      # Remove backup prefix (fixes freezing!)
      unbind C-b
      bind a send-prefix  # Ctrl-s + a sends literal Ctrl-s (like screen)
      
      # Fix terminal responsiveness and WezTerm integration
      set -g focus-events on
      set -g assume-paste-time 1
      
      # Config reload
      unbind r
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "⚙️  Config reloaded"
      
      # Lock mode (like zellij)
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
      
      # Passthrough mode
      bind Escape switch-client -T passthrough
      bind -T passthrough Escape send-keys Escape
      
      # Which-key hints
      set -g @which-key-delay 1000
      bind-key "?" run-shell "~/.config/tmux/plugins/tmux-which-key/tmux-which-key.sh"
      
      # Visual indicators
      set -g window-status-activity-style "fg=#f9e2af,bg=#45475a"
      set -g monitor-activity on
      set -g visual-activity off
      
      # Clipboard and copy mode
      set -s set-clipboard on
      set -g allow-passthrough on
      
      # Vi copy mode bindings
      unbind-key -T copy-mode-vi v
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'C-v' send -X rectangle-toggle
      bind-key -T copy-mode-vi 'C-q' send -X rectangle-toggle
      bind-key -T copy-mode-vi 'y' send -X copy-selection
      
      # Terminal overrides
      set -agsw terminal-overrides ",xterm-256color:RGB"
      set -ag terminal-overrides ",screen-256color:RGB"
      
      # Custom copy mode with line numbers
      unbind [
      bind [ run-shell "~/.config/tmux/scripts/copy_mode_with_line_numbers.sh"
      bind 'v' run-shell "~/.config/tmux/scripts/copy_mode_with_line_numbers.sh"
      
      # Plugin configurations
      set -g @continuum-restore 'on'
    '';
  };

  programs.zellij = {
    enable = true;
    # Note: Zellij config is in KDL format and very complex, better managed as file
    # The HM module doesn't support all the advanced features in the config
  };
  
  # Scripts and additional configs that need to be files
  home.file = {
    # Tmux scripts
    ".config/tmux/scripts".source = ~/.local/share/chezmoi/dot_config/tmux/scripts;
    
    # Additional tmux configs (nvim integration)
    ".config/tmux/tmux.conf.nvim".source = ~/.local/share/chezmoi/dot_config/tmux/tmux.conf.nvim;
    
    # Zellij configuration (no good HM module yet)
    ".config/zellij".source = ~/.local/share/chezmoi/dot_config/zellij;
  };
}