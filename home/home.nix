{ config, pkgs, lib, inputs, ... }:

with lib;  # Add this line to make lib functions available

let
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
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
    ".bash_eww"
    ".bash_local"
    ".clang-format"
    ".envrc"
    ".gitconfig"
    ".p10k.zsh"
    ".profile"
    ".vim"
    ".vst3"
    ".zshenv"
    ".zshrc"
    ".config/fish"
    ".config/fontconfig"
    ".config/gh"
    ".config/ghostty"
    ".config/gtk-3.0"
    ".config/gtk-4.0"
    ".config/hypr"
    ".config/kitty"
    ".config/nix"
    ".config/nvim"
    ".config/omf"
    ".config/sops"
    ".config/tmux"
    ".config/wezterm"
    ".config/zsh"
    "images"
    "modules"
    "scripts"
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
      # zoxide and eza are managed by Homebrew on macOS
      
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
      
      # Browsers and editors
      # brave and code-cursor are managed by Homebrew on macOS
      
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
      vi = "nvim";
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
      wezterm.enable = mkForce false;
      kitty.enable = mkForce false;
      neovim.enable = mkForce false;
    } 
    # Linux-specific applications
    // lib.optionalAttrs isLinux {
      discord.enable = mkForce true;
      telegram.enable = mkForce true;
      steam.enable = mkForce true;
      qbittorrent.enable = mkForce true;
      rofi.enable = mkForce true;
      waybar.enable = mkForce true;
    };
    
    # Shell modules - cross-platform
    shell = {
      fish.enable = mkForce false;
      zoxide.enable = mkForce true;
      bat.enable = mkForce true;
      eza.enable = mkForce true;
    };
    
    # Development modules - cross-platform
    dev = {
      git.enable = mkForce true;
      tmux.enable = mkForce true;
      fzf.enable = mkForce true;
      ripgrep.enable = mkForce true;
      rust.enable = mkForce true;
      nodejs.enable = mkForce true;
      pyenv.enable = mkForce true;
      neovim = {
        enable = mkForce true;
        useVimPlugins = mkForce true;
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
    zsh = {
      enable = false;
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
      enable = mkForce true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };
    eza = {
      enable = mkForce true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };
    lazygit.enable = true;
    
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
