{ config, pkgs, ... }:

{
  # Bat - Cat replacement with syntax highlighting
  programs.bat = {
    enable = true;
    config = {
      # Theme
      theme = "Dracula";

      # Show line numbers and git modifications
      pager = "less -FR";

      # Styling
      style = "numbers,changes,header";
    };
  };

  # Eza - Modern ls replacement
  programs.eza = {
    enable = true;
    enableFishIntegration = true;

    # Git integration and icons
    git = true;
    icons = "auto";

    # Default options
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
  };

  # Yazi - Terminal file manager
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      manager = {
        show_hidden = false;
        sort_by = "natural";
        sort_dir_first = true;
      };
    };
  };

  # Btop - System monitor
  programs.btop = {
    enable = true;
    settings = {
      # Theme
      color_theme = "Default";

      # Update interval
      update_ms = 1000;

      # Display settings
      vim_keys = true;
      rounded_corners = true;

      # Proc settings
      proc_tree = true;
      proc_sorting = "cpu lazy";
    };
  };

  # Broot - Directory navigator
  programs.broot = {
    enable = true;
    enableFishIntegration = true;
  };

  # Nushell - Modern shell
  programs.nushell = {
    enable = true;
  };
}
