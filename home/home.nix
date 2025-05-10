{ config, pkgs, lib, inputs, ... }:

let
  # Platform detection
  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;
  
  # Home directory based on platform
  homeDir = if isLinux
            then lib.mkDefault "/home/ray"
            else lib.mkDefault "/Users/ray";

  # Helper for managing dotfiles
  mkDotfiles = { path, files }:
    builtins.listToAttrs (map
      (file: {
        name = file;
        value = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${path}/${file}";
        };
      })
      files);

  # Dotfiles to link
  dotfiles = [
    ".aliasrc"
    ".bashrc"
    ".fonts"
    ".gitconfig"
    ".p10k.zsh"
    ".clang-format"
    ".zshrc"
    ".oh-my-bash"
    ".vst3"
    "images"
    "programs"
    "modules"
    "notes"
  ];
  
  # Define platform-specific packages
  pkgSets = rec {
    # Cross-platform packages
    common = with pkgs; [
      # Shell utilities
      bat
      fzf
      fastfetch
      git
      lazygit
      zoxide
      
      # Development tools
      git-repo
      luarocks
      nixd
      nodejs_22
      ripgrep
      rustup
      stow
      tmux
      
      # Terminal emulators
      wezterm
      kitty
      
      # Other utilities
      unzip
      oh-my-fish
    ];
    
    # Linux-only packages
    linux = with pkgs; [
      rofi
      discord
      telegram-desktop
      steam
      qbittorrent
      code-cursor
    ];
    
    # All packages combined by platform
    all = common ++ (if isLinux then linux else []);
  };
in
{
  # Basic configuration
  home = {
    username = "ray";
    homeDirectory = homeDir;
    stateVersion = "24.11";
    
    # Shell aliases
    shellAliases = {
      v = "nvim";
      vim = "nvim";
      g = "git";
    };
    
    # Session configuration
    sessionPath = [ ];
    sessionVariables = {
      EDITOR = "nvim";
    };
    
    # Package installation
    packages = pkgSets.all;
    
    # Dotfiles management
    file = mkDotfiles {
      path = ".dotfiles";
      files = dotfiles;
    };
  };

  # Set the active profile and desktop environment
  ray.home.profiles = {
    active = "desktop";
    desktopEnvironment = "gnome";
  };

  # Enable modules with platform-specific configuration
  ray.home.modules = {
    # Cross-platform applications
    apps = {
      wezterm.enable = true;
      kitty.enable = true;
      neovim.enable = false;
    } 
    # Linux-specific applications
    // lib.optionalAttrs isLinux {
      discord.enable = true;
      telegram.enable = true;
      steam.enable = true;
      qbittorrent.enable = true;
      rofi.enable = true;
      waybar.enable = true;
    };
    
    # Shell modules - cross-platform
    shell = {
      fish.enable = true;
      zoxide.enable = true;
      bat.enable = true;
      eza.enable = true;
    };
    
    # Development modules - cross-platform
    dev = {
      git.enable = true;
      tmux.enable = true;
      fzf.enable = true;
      ripgrep.enable = true;
      rust.enable = true;
      nodejs.enable = true;
      pyenv.enable = true;
      neovim = {
        enable = true;
        useVimPlugins = true;
      };
    };
  };

  # Import modules
  imports = [
    ./modules/apps
    ./modules/shell
    ./modules/dev
    ./profiles
  ];

  # Programs configuration
  programs = {
    # Shell configuration
    bash = {
      initExtra = ''
        if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
        fi
      '';
    };
    
    fish = {
      enable = true;
      plugins = [
        {
          name = "oh-my-fish";
          src = pkgs.oh-my-fish;
        }
      ];
      shellAliases = {
        g = "git";
      };
    };
    
    # Git configuration
    git = {
      enable = true;
      userEmail = "ray@example.com";
      userName = "ray";
      aliases = {
        i = "init";
        aa = "add .";
        co = "commit";
        ca = "commit -a";
        cm = "commit -am";
        ps = "push";
        pu = "pull";
        stu = "status HEAD";
        sts = "stash";
        sw = "switch";
        di = "diff";
      };
    };
    
    # Tmux configuration
    tmux = {
      enable = false;
      plugins = with pkgs.tmuxPlugins; [
        catppuccin
        jump
        yank
        tmux-fzf
        sensible
        resurrect
        continuum
        mode-indicator
        vim-tmux-navigator
      ];
      mouse = true;
      prefix = "C-s";
      clock24 = true;
      keyMode = "vi";
    };
    
    # Other programs
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };
    eza.enable = true;
    wezterm.enable = false;
    lazygit.enable = true;
    pyenv.enable = true;
    
    # Enable home-manager
    home-manager.enable = true;
  };

  # Services configuration
  services = {
    syncthing = {
      enable = true;
    };
  };
}
