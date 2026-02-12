{ config, pkgs, ... }:

{
  # Tmux - Terminal multiplexer
  programs.tmux = {
    enable = true;

    # Basic settings
    baseIndex = 1;  # Start window numbering at 1
    clock24 = true;
    escapeTime = 0;  # No delay for escape key
    historyLimit = 10000;
    keyMode = "vi";  # Vi-style key bindings
    mouse = true;  # Enable mouse support
    terminal = "screen-256color";

    # Keybindings
    prefix = "C-a";  # Change prefix from C-b to C-a

    # Extra configuration
    extraConfig = ''
      # Better split defaults
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Easy config reload
      bind r source-file ~/.tmux.conf \; display "Config reloaded!"

      # Vi-style pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Status bar
      set -g status-style 'bg=#333333 fg=#5eacd3'
      set -g status-left-length 20
      set -g status-right '%Y-%m-%d %H:%M '

      # Window status
      setw -g window-status-current-style 'fg=#ffffff bg=#5eacd3 bold'
    '';
  };

  # Zellij - Modern terminal multiplexer
  programs.zellij = {
    enable = true;

    # Enable shell integrations
    enableFishIntegration = true;

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
