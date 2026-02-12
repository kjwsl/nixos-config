{ config, pkgs, lib, ... }:

{
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    
    settings = {
      manager = {
        sort_by = "natural";
        sort_sensitive = false;
        sort_reverse = false;
        sort_dir_first = false;
        sort_translit = true;
        show_hidden = true;
        show_symlink = true;
        scrolloff = 30;
      };
      
      preview = {
        wrap = "yes";
        tab_size = 4;
      };
      
      opener = {
        view = [
          { run = ''feh "$@"''; desc = "View Image with feh"; for = "unix"; }
        ];
      };
      
      open = {
        prepend_rules = [
          { name = "*.png"; use = "view"; }
          { name = "*.jpg"; use = "view"; }
          { name = "*.jpeg"; use = "view"; }
        ];
      };
    };
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "catppuccin_mocha";
      theme_background = true;
      truecolor = true;
      force_tty = false;
      vim_keys = true;
      rounded_corners = true;
      graph_symbol = "braille";
      shown_boxes = "cpu mem net proc";
      update_ms = 2000;
      proc_sorting = "cpu lazy";
      proc_reversed = false;
      proc_tree = false;
      check_temp = true;
      cpu_graph_upper = "total";
      cpu_graph_lower = "total";
      cpu_invert_lower = true;
      cpu_single_graph = false;
      cpu_bottom = false;
      show_uptime = true;
      check_cpu_temp = true;
      cpu_sensor = "Auto";
      show_coretemp = true;
      temp_scale = "celsius";
      show_battery = true;
      show_cpu_freq = true;
      mem_graphs = true;
      show_swap = true;
      swap_disk = true;
      show_disks = true;
      only_physical = true;
      use_fstab = false;
      show_io_stat = true;
      io_mode = false;
      io_graph_combined = false;
      net_download = 100;
      net_upload = 100;
      net_auto = true;
      net_color_fixed = false;
      net_iface = "";
      log_level = "WARNING";
    };
  };

  programs.fastfetch = {
    enable = true;
    # Configuration will be managed via file since HM module is limited
  };
  
  # File-based configurations for tools that need complex configs or don't have good HM modules
  home.file = {
    # Yazi theme (complex theme file)
    ".config/yazi/theme.toml".source = ~/.local/share/chezmoi/dot_config/yazi/theme.toml;
    ".config/yazi/keymap.toml".source = ~/.local/share/chezmoi/dot_config/yazi/keymap.toml;
    
    # Btop theme
    ".config/btop/themes".source = ~/.local/share/chezmoi/dot_config/btop/themes;
    
    # Fastfetch config
    ".config/fastfetch".source = ~/.local/share/chezmoi/dot_config/fastfetch;
    
    # Development and shell tools with complex configs
    ".config/nushell".source = ~/.local/share/chezmoi/dot_config/nushell;
    ".config/sheldon".source = ~/.local/share/chezmoi/dot_config/sheldon;
    ".config/omf".source = ~/.local/share/chezmoi/dot_config/omf;
    ".config/zsh".source = ~/.local/share/chezmoi/dot_config/zsh;
    
    # Security and privacy tools
    ".config/sops".source = ~/.local/share/chezmoi/dot_config/sops;
    ".config/syncthing".source = ~/.local/share/chezmoi/dot_config/syncthing;
    
    # AI and language tools
    ".config/ai".source = ~/.local/share/chezmoi/dot_config/ai;
    ".config/harper-ls".source = ~/.local/share/chezmoi/dot_config/harper-ls;
    ".config/goose".source = ~/.local/share/chezmoi/dot_config/goose;
    
    # Media and download tools
    ".config/yt-dlp".source = ~/.local/share/chezmoi/dot_config/yt-dlp;
    ".config/pulse".source = ~/.local/share/chezmoi/dot_config/pulse;
    ".config/qBittorrent".source = ~/.local/share/chezmoi/dot_config/qBittorrent;
    
    # Version control and development
    ".config/private_jj".source = ~/.local/share/chezmoi/dot_config/private_jj;
    
    # System info tools
    ".config/neofetch".source = ~/.local/share/chezmoi/dot_config/neofetch;
    
    # Nix configuration
    ".config/nix".source = ~/.local/share/chezmoi/dot_config/nix;
  };
}