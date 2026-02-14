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

  # just - Command runner (managed via home.packages in home.nix)
  # Deprecated: programs.just.enable removed, just added to packages instead

  # Direnv - Auto-load environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Zoxide - Smarter cd (already configured in shell.nix)
  # Fzf - Fuzzy finder (already configured in shell.nix)
  # Atuin - Better shell history (already configured in shell.nix)

  # Additional cool CLI tools
  home.packages = with pkgs; [
    # Modern replacements
    bandwhich     # Network bandwidth monitor
    procs         # Modern ps replacement
    sd            # sed alternative (simpler syntax)
    choose        # cut alternative

    # Productivity
    navi          # Interactive cheatsheet
    tealdeer      # tldr client (quick command help)

    # Monitoring
    zenith        # htop alternative with charts

    # Development
    tokei         # Code statistics
    onefetch      # Git repository info

    # File operations
    xcp           # Extended cp (better progress)
    ouch          # Compression tool (handles all formats)

    # Network
    curlie        # curl with httpie syntax
    xh            # httpie alternative

    # Fun/useful
    glow          # Already in home.nix, keeping for consistency
    silicon       # Code screenshot tool
  ];
}
