{ config, pkgs, lib, ... }:

{
  programs.tmux = {
    enable = true;
    clock24 = true;
    escapeTime = 10;  # Fix terminal responsiveness 
    historyLimit = 50000;  # Increased for power users
    keyMode = "vi";
    prefix = "C-s";    # Change prefix from default C-b to C-s
    mouse = true;
    sensibleOnTop = true;
    terminal = "tmux-256color";
    baseIndex = 1;     # Start windows at 1, not 0
    
    plugins = with pkgs.tmuxPlugins; [
      # Theme and visual enhancements
      {
        plugin = tmux-nova;
        extraConfig = ''
          # tmux-nova configuration (Catppuccin Mocha) - Enhanced status bar
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
          
          # Enhanced segments for power users
          set -g @nova-segment-mode "#{?client_prefix,⌨️  PREFIX,#{?pane_in_mode,📋 COPY,#{?pane_synchronized,🔄 SYNC,#{?window_zoomed_flag,🔍 ZOOM,}}}}"
          set -g @nova-segment-mode-colors "#fab387 #1e1e2e"
          
          set -g @nova-segment-session " #S"
          set -g @nova-segment-session-colors "#a6e3a1 #1e1e2e"
          
          set -g @nova-segment-cpu " #{cpu_percentage}"
          set -g @nova-segment-cpu-colors "#f9e2af #1e1e2e"
          
          set -g @nova-segment-memory " #{ram_percentage}"
          set -g @nova-segment-memory-colors "#fab387 #1e1e2e"
          
          set -g @nova-segment-battery "#{battery_icon} #{battery_percentage}"
          set -g @nova-segment-battery-colors "#f38ba8 #1e1e2e"
          
          set -g @nova-segment-load " #{load_average}"
          set -g @nova-segment-load-colors "#cba6f7 #1e1e2e"
          
          set -g @nova-segment-git " #{git_branch}"
          set -g @nova-segment-git-colors "#a6e3a1 #1e1e2e"
          
          set -g @nova-segment-weather "#{weather}"
          set -g @nova-segment-weather-colors "#94e2d5 #1e1e2e"
          
          set -g @nova-segment-time " %H:%M"
          set -g @nova-segment-time-colors "#89b4fa #1e1e2e"
          
          set -g @nova-segment-hostname " #h"
          set -g @nova-segment-hostname-colors "#b4befe #1e1e2e"
          
          # Pane format with enhanced info
          set -g @nova-pane "#I#{?pane_in_mode,  #{pane_mode},}  #W#{?window_zoomed_flag, 🔍,}"
          set -g @nova-pane-justify "left"
          
          # Multi-row status bar for more info
          set -g @nova-rows 1
          set -g @nova-segments-0-left "mode session"
          set -g @nova-segments-0-right "git cpu memory load battery time hostname"
        '';
      }
      
      # Core functionality plugins
      better-mouse-mode
      sensible
      yank
      open
      
      # System monitoring
      battery
      cpu
      {
        plugin = sysstat;
        extraConfig = ''
          set -g @sysstat_cpu_view_tmpl '#[fg=#f9e2af]C:#[default] #[fg=#{cpu.color}]#{cpu.pused}#[default]'
          set -g @sysstat_mem_view_tmpl '#[fg=#fab387]M:#[default] #[fg=#{mem.color}]#{mem.pused}#[default]'
          set -g @sysstat_loadavg_view_tmpl '#[fg=#cba6f7]L:#[default] #[fg=#{loadavg.color}]#{loadavg.avg1}#[default]'
        '';
      }
      
      # Session management and productivity
      {
        plugin = resurrect;
        extraConfig = ''
          # Enhanced resurrect settings
          set -g @resurrect-save-bash-history 'on'
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-processes 'ssh,mosh,watch,top,htop,btop,man,less,more,tail,vim,nvim'
          
          # Save sessions more frequently
          set -g @resurrect-save-interval '5'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          # Automatic restore and save
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '5'
          set -g @continuum-boot 'on'
          set -g @continuum-boot-options 'alacritty,fullscreen'
        '';
      }
      
      # Navigation and control
      pain-control
      {
        plugin = tmux-thumbs;
        extraConfig = ''
          # Quick text copying with hints
          set -g @thumbs-key 'Space'
          set -g @thumbs-alphabet 'qwerty-homerow'
          set -g @thumbs-reverse 'true'
          set -g @thumbs-unique 'true'
          set -g @thumbs-position 'off_left'
          set -g @thumbs-hint-bg-color '#fab387'
          set -g @thumbs-hint-fg-color '#1e1e2e'
          set -g @thumbs-select-bg-color '#a6e3a1'
          set -g @thumbs-select-fg-color '#1e1e2e'
        '';
      }
      {
        plugin = extrakto;
        extraConfig = ''
          # Advanced text extraction
          set -g @extrakto_key 'e'
          set -g @extrakto_grab_area 'full'
          set -g @extrakto_copy_key 'tab'
          set -g @extrakto_insert_key 'enter'
          set -g @extrakto_filter_order 'line url path file ip hash'
          set -g @extrakto_split_direction 'p'
          set -g @extrakto_split_size '7'
          set -g @extrakto_popup_size '70%,60%'
          set -g @extrakto_popup_position 'C'
        '';
      }
      {
        plugin = tmux-fzf;
        extraConfig = ''
          # Enhanced FZF integration with custom bindings
          set -g @tmux-fzf-launch-key "C-f"
          bind-key "f" run-shell -b "~/.config/tmux/plugins/tmux-fzf/scripts/session.sh switch"
          bind-key "w" run-shell -b "~/.config/tmux/plugins/tmux-fzf/scripts/window.sh switch"
          bind-key "p" run-shell -b "~/.config/tmux/plugins/tmux-fzf/scripts/pane.sh switch"
        '';
      }
      {
        plugin = sessionist;
        extraConfig = ''
          # Advanced session management
          set -g @sessionist-bind-new 'C-c'
          set -g @sessionist-bind-kill-session 'X'
          set -g @sessionist-bind-alternate 'L'
          set -g @sessionist-bind-promote-pane 'P'
          set -g @sessionist-bind-join-pane 'J'
        '';
      }
      {
        plugin = tmux-cowboy;
        extraConfig = ''
          # Kill unresponsive programs
          set -g @cowboy-key 'k'
          set -g @cowboy-kill-key 'K'
        '';
      }
      
      # Integration and workflow
      {
        plugin = prefix-highlight;
        extraConfig = ''
          # Visual prefix indicator
          set -g status-position top
          set -g @prefix_highlight_prefix_prompt ' '
          set -g @prefix_highlight_copy_prompt ' '
          set -g @prefix_highlight_sync_prompt ' '
          set -g @prefix_highlight_fg '#1e1e2e'
          set -g @prefix_highlight_bg '#fab387'
          set -g @prefix_highlight_show_copy_mode 'on'
          set -g @prefix_highlight_show_sync_mode 'on'
        '';
      }
      logging
    ];
    
    extraConfig = ''
      # ===== POWER USER TMUX CONFIGURATION =====
      
      # Remove backup prefix (fixes freezing!)
      unbind C-b
      bind a send-prefix  # Ctrl-s + a sends literal Ctrl-s (like screen)
      
      # Enhanced terminal integration
      set -g focus-events on
      set -g assume-paste-time 1
      set-option -sa terminal-features ',XXX:RGB'
      set-option -ga terminal-overrides ',XXX:Tc'
      set -ag terminal-overrides ",xterm-256color:RGB,screen-256color:RGB"
      
      # ===== POPUP TERMINALS (PREFIX + KEY) =====
      
      # Popup terminal (prefix + t)
      bind t display-popup -E -w 80% -h 80% -d "#{pane_current_path}"
      
      # Popup lazygit (prefix + g)  
      bind g display-popup -E -w 90% -h 90% -d "#{pane_current_path}" "lazygit"
      
      # Popup btop/htop (prefix + b)
      bind b display-popup -E -w 80% -h 80% "btop || htop"
      
      # Popup tig for git browsing (prefix + T)  
      bind T display-popup -E -w 90% -h 90% -d "#{pane_current_path}" "tig"
      
      # Popup file manager with yazi (prefix + y)
      bind y display-popup -E -w 90% -h 90% -d "#{pane_current_path}" "yazi"
      
      # ===== ADVANCED SESSION MANAGEMENT =====
      
      # Session fuzzy finder (prefix + s enhanced)
      bind s display-popup -E -w 60% -h 60% "tmux list-sessions -F '#{session_name}' | fzf --reverse | xargs tmux switch-client -t"
      
      # New session with name prompt
      bind S command-prompt -p "New session name:" "new-session -d -s %1 ; switch-client -t %1"
      
      # Quick session jumper (prefix + j)
      bind j display-popup -E -w 50% -h 40% "echo 'Quick jump:'; read session; tmux new-session -d -s $session 2>/dev/null; tmux switch-client -t $session"
      
      # ===== ENHANCED WINDOW/PANE MANAGEMENT =====
      
      # Smart pane switching with awareness of Vim splits
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
      bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
      bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'  
      bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
      bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'
      
      tmux_version='$(tmux display-message -p "#{version}" | sed "s/[^0-9.].*//g")'
      if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
        "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\' 'select-pane -l'"
      if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
        "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\' 'select-pane -l'"
      
      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R
      bind-key -T copy-mode-vi 'C-\\' select-pane -l
      
      # Enhanced window switching
      bind -n M-H previous-window
      bind -n M-L next-window
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-6 select-window -t 6
      bind -n M-7 select-window -t 7
      bind -n M-8 select-window -t 8
      bind -n M-9 select-window -t 9
      
      # Window reordering
      bind-key -n C-S-Left swap-window -t -1\; select-window -t -1
      bind-key -n C-S-Right swap-window -t +1\; select-window -t +1
      
      # ===== LOCK MODE (LIKE ZELLIJ) =====
      
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
      
      # ===== PASSTHROUGH MODE =====
      
      bind Escape switch-client -T passthrough
      bind -T passthrough Escape send-keys Escape
      
      # ===== CONFIG & HELP =====
      
      # Config reload
      unbind r
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "⚙️  Config reloaded"
      
      # Which-key style help  
      set -g @which-key-delay 1000
      bind-key "?" run-shell "~/.config/tmux/plugins/tmux-which-key/tmux-which-key.sh"
      
      # ===== VISUAL SETTINGS =====
      
      # Activity monitoring
      set -g window-status-activity-style "fg=#f9e2af,bg=#45475a"
      set -g monitor-activity on
      set -g visual-activity off
      
      # Bell settings
      set -g bell-action any
      set -g visual-bell off
      
      # ===== COPY MODE ENHANCEMENTS =====
      
      # Clipboard integration
      set -s set-clipboard on
      set -g allow-passthrough on
      
      # Enhanced vi copy mode bindings
      unbind-key -T copy-mode-vi v
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'C-v' send -X rectangle-toggle
      bind-key -T copy-mode-vi 'C-q' send -X rectangle-toggle
      bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel
      bind-key -T copy-mode-vi 'Y' send -X copy-line
      bind-key -T copy-mode-vi 'A' send -X append-selection-and-cancel
      
      # Copy mode with line numbers
      unbind [
      bind [ run-shell "~/.config/tmux/scripts/copy_mode_with_line_numbers.sh"
      bind 'v' run-shell "~/.config/tmux/scripts/copy_mode_with_line_numbers.sh"
      
      # ===== AUTOMATIC WINDOW NAMING =====
      
      set-option -g automatic-rename on
      set-option -g automatic-rename-format '#{b:pane_current_path}'
      
      # ===== PANE BORDERS =====
      
      set -g pane-border-style 'fg=#45475a'
      set -g pane-active-border-style 'fg=#89b4fa'
      
      # Show pane numbers longer
      set -g display-panes-time 2000
      
      # ===== MESSAGE SETTINGS =====
      
      set -g message-style 'fg=#cdd6f4 bg=#313244'
      set -g message-command-style 'fg=#cdd6f4 bg=#313244'
      
      # ===== STATUS BAR POSITIONING =====
      
      set -g status-position top
      set -g status-justify left
      
      # ===== PERFORMANCE OPTIMIZATIONS =====
      
      set -g display-time 2000
      set -g repeat-time 1000
      set -g remain-on-exit off
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