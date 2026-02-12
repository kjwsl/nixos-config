{ config, pkgs, ... }:

{
  # Tmux - Terminal multiplexer
  programs.tmux = {
    enable = true;

    # Basic settings
    baseIndex = 1;  # Start window numbering at 1
    clock24 = true;
    escapeTime = 0;  # No delay for escape key
    historyLimit = 50000;  # Increased history
    keyMode = "vi";  # Vi-style key bindings
    mouse = true;  # Enable mouse support
    terminal = "screen-256color";
    
    # Sensible defaults
    sensibleOnTop = true;

    # Keybindings
    prefix = "C-a";  # Change prefix from C-b to C-a

    # Plugins
    plugins = with pkgs.tmuxPlugins; [
      # ============================================
      # CORE FUNCTIONALITY
      # ============================================
      sensible
      pain-control  # Better pane control
      
      # ============================================
      # SESSION MANAGEMENT
      # ============================================
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-processes 'ssh mysql psql redis-cli'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
          set -g @continuum-boot 'on'
          set -g @continuum-boot-options 'iterm,fullscreen'
        '';
      }
      
      # ============================================
      # COPY/PASTE & TEXT MANIPULATION
      # ============================================
      {
        plugin = yank;
        extraConfig = ''
          set -g @yank_selection 'clipboard'
          set -g @yank_selection_mouse 'clipboard'
          set -g @yank_action 'copy-pipe-no-clear'
        '';
      }
      copycat  # Regex searches and highlights
      open  # Open highlighted files/URLs
      
      # ============================================
      # NAVIGATION & SEARCH
      # ============================================
      {
        plugin = fzf-tmux-url;
        extraConfig = ''
          set -g @fzf-url-bind 'u'
          set -g @fzf-url-history-limit '2000'
        '';
      }
      
      # ============================================
      # SYSTEM MONITORING
      # ============================================
      {
        plugin = cpu;
        extraConfig = ''
          set -g @cpu_low_icon "✓"
          set -g @cpu_medium_icon "⚠"
          set -g @cpu_high_icon "✗"
          set -g @cpu_low_fg_color "#[fg=#00ff00]"
          set -g @cpu_medium_fg_color "#[fg=#ffff00]"
          set -g @cpu_high_fg_color "#[fg=#ff0000]"
        '';
      }
      {
        plugin = battery;
        extraConfig = ''
          set -g @batt_icon_charge_tier8 '🌕'
          set -g @batt_icon_charge_tier7 '🌖'
          set -g @batt_icon_charge_tier6 '🌖'
          set -g @batt_icon_charge_tier5 '🌗'
          set -g @batt_icon_charge_tier4 '🌗'
          set -g @batt_icon_charge_tier3 '🌘'
          set -g @batt_icon_charge_tier2 '🌘'
          set -g @batt_icon_charge_tier1 '🌑'
          set -g @batt_icon_status_charged '🔋'
          set -g @batt_icon_status_charging '⚡'
          set -g @batt_icon_status_discharging '👎'
        '';
      }
      
      # ============================================
      # VISUAL ENHANCEMENTS
      # ============================================
      {
        plugin = mode-indicator;
        extraConfig = ''
          set -g @mode_indicator_prefix_prompt ' WAIT '
          set -g @mode_indicator_copy_prompt ' COPY '
          set -g @mode_indicator_sync_prompt ' SYNC '
          set -g @mode_indicator_empty_prompt ' TMUX '
          set -g @mode_indicator_prefix_mode_style 'bg=blue,fg=black'
          set -g @mode_indicator_copy_mode_style 'bg=yellow,fg=black'
          set -g @mode_indicator_sync_mode_style 'bg=red,fg=black'
          set -g @mode_indicator_empty_mode_style 'bg=cyan,fg=black'
        '';
      }
      prefix-highlight
      
      # ============================================
      # THEME - Catppuccin (Modern & Beautiful)
      # ============================================
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour 'mocha' # latte, frappe, macchiato, mocha
          set -g @catppuccin_window_left_separator ""
          set -g @catppuccin_window_right_separator " "
          set -g @catppuccin_window_middle_separator " █"
          set -g @catppuccin_window_number_position "right"
          set -g @catppuccin_window_default_fill "number"
          set -g @catppuccin_window_default_text "#W"
          set -g @catppuccin_window_current_fill "number"
          set -g @catppuccin_window_current_text "#W#{?window_zoomed_flag,(),}"
          
          # Status modules with system info
          set -g @catppuccin_status_modules_right "application session cpu battery date_time"
          set -g @catppuccin_status_modules_left "directory"
          set -g @catppuccin_status_left_separator  " "
          set -g @catppuccin_status_right_separator " "
          set -g @catppuccin_status_right_separator_inverse "no"
          set -g @catppuccin_status_fill "icon"
          set -g @catppuccin_status_connect_separator "no"
          set -g @catppuccin_directory_text "#{b:pane_current_path}"
          set -g @catppuccin_date_time_text "%H:%M"
          set -g @catppuccin_application_icon ""
          set -g @catppuccin_session_icon ""
        '';
      }
    ];

    # Extra configuration
    extraConfig = ''
      # ============================================
      # TRUE COLOR SUPPORT
      # ============================================
      set -g default-terminal "screen-256color"
      set -ga terminal-overrides ",xterm-256color:Tc"
      
      # ============================================
      # WINDOW & PANE MANAGEMENT
      # ============================================
      # Better split defaults (open in current path)
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # New window in current path
      bind c new-window -c "#{pane_current_path}"

      # Easy config reload
      bind r source-file ~/.config/tmux/tmux.conf \; display "⚙ Config reloaded!"

      # Vi-style pane navigation (still available with prefix)
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Pane resizing
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Quick pane cycling
      bind -r Tab select-pane -t :.+

      # Zoom pane
      bind -r z resize-pane -Z

      # ============================================
      # COPY MODE IMPROVEMENTS
      # ============================================
      # Vi-style copy mode
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # Copy to system clipboard (macOS)
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"

      # ============================================
      # WINDOW MANAGEMENT
      # ============================================
      # Window navigation
      bind -r C-h previous-window
      bind -r C-l next-window

      # Swap windows
      bind -r "<" swap-window -d -t -1
      bind -r ">" swap-window -d -t +1

      # Renumber windows automatically
      set -g renumber-windows on

      # ============================================
      # VISUAL IMPROVEMENTS
      # ============================================
      # Pane borders
      set -g pane-border-style 'fg=colour238'
      set -g pane-active-border-style 'fg=colour81'

      # Message style
      set -g message-style 'fg=colour232 bg=colour166 bold'

      # Aggressive resize (useful for multi-monitor)
      setw -g aggressive-resize on

      # Activity monitoring
      setw -g monitor-activity on
      set -g visual-activity off
      
      # Better pane numbering display
      set -g display-panes-time 2000
      set -g display-panes-colour colour166
      set -g display-panes-active-colour colour81

      # ============================================
      # SESSION MANAGEMENT
      # ============================================
      # Session navigation
      bind S choose-session

      # Quick session switching
      bind -r ( switch-client -p
      bind -r ) switch-client -n

      # ============================================
      # RESURRECT/CONTINUUM SETTINGS
      # ============================================
      set -g @resurrect-strategy-nvim 'session'
      set -g @resurrect-capture-pane-contents 'on'
      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '15' # minutes

      # ============================================
      # NEOVIM INTEGRATION (from tmux.conf.nvim)
      # ============================================
      # Smart pane switching with awareness of Neovim splits.
      bind-key -n C-h if -F "#{@pane-is-vim}" 'send-keys C-h'  'select-pane -L'
      bind-key -n C-j if -F "#{@pane-is-vim}" 'send-keys C-j'  'select-pane -D'
      bind-key -n C-k if -F "#{@pane-is-vim}" 'send-keys C-k'  'select-pane -U'
      bind-key -n C-l if -F "#{@pane-is-vim}" 'send-keys C-l'  'select-pane -R'

      # Smart pane resizing with awareness of Neovim splits.
      bind-key -n M-h if -F "#{@pane-is-vim}" 'send-keys M-h' 'resize-pane -L 3'
      bind-key -n M-j if -F "#{@pane-is-vim}" 'send-keys M-j' 'resize-pane -D 3'
      bind-key -n M-k if -F "#{@pane-is-vim}" 'send-keys M-k' 'resize-pane -U 3'
      bind-key -n M-l if -F "#{@pane-is-vim}" 'send-keys M-l' 'resize-pane -R 3'

      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R

      # ============================================
      # QUALITY OF LIFE
      # ============================================
      # Don't exit copy mode when scrolling to bottom
      bind-key -T copy-mode-vi WheelDownPane select-pane \; send-keys -X clear-selection

      # Clear screen and history
      bind C-k send-keys -R \; clear-history

      # Set titles
      set -g set-titles on
      set -g set-titles-string "#T"

      # No bells
      set -g visual-bell off
      set -g bell-action none

      # Focus events enabled for terminals that support them
      set -g focus-events on
      
      # Open new windows/panes in same directory by default
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      
      # Synchronize panes
      bind C-s setw synchronize-panes
      
      # Break pane to new window
      bind b break-pane -d
      
      # Join pane from another window
      bind-key j command-prompt -p "join pane from:"  "join-pane -s '%%'"
      
      # Send pane to another window
      bind-key s command-prompt -p "send pane to:"  "join-pane -t '%%'"
      
      # Swap current pane with marked pane
      bind C-o swap-pane
      
      # Toggle mouse mode
      bind m set -g mouse
      
      # Quick layout switches
      bind M-1 select-layout even-horizontal
      bind M-2 select-layout even-vertical
      bind M-3 select-layout main-horizontal
      bind M-4 select-layout main-vertical
      bind M-5 select-layout tiled
    '';
  };

  # Zellij - Modern terminal multiplexer
  programs.zellij = {
    enable = true;

    # Disable auto-start on fish shell
    enableFishIntegration = false;

    # Basic settings
    settings = {
      # Theme
      theme = "default";

      # UI settings
      pane_frames = true;
      simplified_ui = false;

      # Default shell
      default_shell = "fish";

      # Copy settings
      copy_command = "pbcopy";  # macOS clipboard
      copy_on_select = true;

      # Mouse support
      mouse_mode = true;

      # Scroll settings
      scroll_buffer_size = 10000;
    };
  };
}
