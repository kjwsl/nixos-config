{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.shell.fastfetch;

  # Predefined color themes
  themes = {
    catppuccin = {
      title = "mauve";
      subtitle = "mauve";
      separator = "mauve";
      keys = "blue";
      values = "text";
    };
    
    tokyonight = {
      title = "magenta";
      subtitle = "magenta";
      separator = "magenta";
      keys = "blue";
      values = "white";
    };
    
    dracula = {
      title = "purple";
      subtitle = "purple";
      separator = "purple";
      keys = "cyan";
      values = "white";
    };
    
    nord = {
      title = "blue";
      subtitle = "blue";
      separator = "blue";
      keys = "cyan";
      values = "white";
    };
    
    gruvbox = {
      title = "yellow";
      subtitle = "yellow";
      separator = "yellow";
      keys = "green";
      values = "white";
    };
    
    solarized = {
      title = "blue";
      subtitle = "blue";
      separator = "blue";
      keys = "cyan";
      values = "white";
    };
    
    monokai = {
      title = "magenta";
      subtitle = "magenta";
      separator = "magenta";
      keys = "green";
      values = "white";
    };
    
    one-dark = {
      title = "red";
      subtitle = "red";
      separator = "red";
      keys = "blue";
      values = "white";
    };
    
    # Default theme
    default = {
      title = "blue";
      subtitle = "blue";
      separator = "blue";
      keys = "blue";
      values = "white";
    };
  };
in
{
  options.ray.home.modules.shell.fastfetch = {
    enable = mkEnableOption "fastfetch for fast system information";
    
    settings = {
      logo = mkOption {
        type = types.str;
        default = "nixos";
        description = "The logo to display (e.g., nixos, arch, debian)";
      };
      
      display = mkOption {
        type = types.listOf types.str;
        default = [ "title" "os" "host" "kernel" "packages" "shell" "de" "wm" "terminal" "cpu" "gpu" "memory" "disk" "uptime" ];
        description = "The information to display";
      };

      # Theme selection
      theme = mkOption {
        type = types.enum (builtins.attrNames themes);
        default = "default";
        description = "Predefined color theme to use";
      };

      # Color customization (overrides theme if set)
      colors = {
        title = mkOption {
          type = types.str;
          default = themes.default.title;
          description = "Color for the title (e.g., blue, red, green, yellow, magenta, cyan, white)";
        };

        subtitle = mkOption {
          type = types.str;
          default = themes.default.subtitle;
          description = "Color for the subtitle";
        };

        separator = mkOption {
          type = types.str;
          default = themes.default.separator;
          description = "Color for the separator";
        };

        keys = mkOption {
          type = types.str;
          default = themes.default.keys;
          description = "Color for the keys";
        };

        values = mkOption {
          type = types.str;
          default = themes.default.values;
          description = "Color for the values";
        };
      };

      # Layout customization
      layout = {
        logoPadding = mkOption {
          type = types.int;
          default = 2;
          description = "Padding between logo and text";
        };

        keyWidth = mkOption {
          type = types.int;
          default = 10;
          description = "Width of the key column";
        };

        separator = mkOption {
          type = types.str;
          default = ":";
          description = "Separator between keys and values";
        };

        small = mkOption {
          type = types.bool;
          default = false;
          description = "Use small logo";
        };

        hideLogo = mkOption {
          type = types.bool;
          default = false;
          description = "Hide the logo completely";
        };
      };

      # Performance options
      performance = {
        multithreading = mkOption {
          type = types.bool;
          default = true;
          description = "Enable multithreading for faster execution";
        };

        cache = mkOption {
          type = types.bool;
          default = true;
          description = "Enable caching for faster subsequent runs";
        };

        cacheTimeout = mkOption {
          type = types.int;
          default = 60;
          description = "Cache timeout in seconds";
        };
      };

      # Display options
      displayOptions = {
        showErrors = mkOption {
          type = types.bool;
          default = false;
          description = "Show errors in the output";
        };

        showWarnings = mkOption {
          type = types.bool;
          default = false;
          description = "Show warnings in the output";
        };

        showDebug = mkOption {
          type = types.bool;
          default = false;
          description = "Show debug information";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    programs.fastfetch = {
      enable = true;
      
      # Apply custom settings
      settings = let
        selectedTheme = themes.${cfg.settings.theme};
        # Use custom colors if set, otherwise use theme colors
        colors = if cfg.settings.colors.title != themes.default.title
          then cfg.settings.colors
          else selectedTheme;
      in {
        inherit (cfg.settings) logo display;
        
        # Colors (use theme or custom colors)
        colors = {
          inherit (colors) title subtitle separator keys values;
        };
        
        # Layout
        layout = {
          inherit (cfg.settings.layout) logoPadding keyWidth separator small hideLogo;
        };
        
        # Performance
        performance = {
          inherit (cfg.settings.performance) multithreading cache cacheTimeout;
        };
        
        # Display options
        displayOptions = {
          inherit (cfg.settings.displayOptions) showErrors showWarnings showDebug;
        };
      };
    };
    
    # Make fastfetch available in the environment
    home.packages = [ pkgs.fastfetch ];
  };
}

