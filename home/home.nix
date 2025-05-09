{ config, pkgs, lib, inputs, ... }:

let
  homeDir =
    if pkgs.stdenv.isLinux
    then lib.mkDefault "/home/ray"
    else lib.mkDefault "/Users/ray";

  mkDotfiles = { path, files }:
    builtins.listToAttrs (map
      (file: {
        name = file;
        value = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${path}/${file}";
        };
      })
      files);

in
{
  # Basic configuration
  home.username = "ray";
  home.homeDirectory = homeDir;
  home.stateVersion = "24.11";

  # Set the active profile and desktop environment
  ray.home = {
    profiles = {
      active = "desktop";
      desktopEnvironment = "gnome";
    };
  };

  # Shell aliases
  home.shellAliases = {
    v = "nvim";
    vim = "nvim";
    g = "git";
    ls = "ls -ah --color";
    ll = "ls -lah --color";
  };

  # Enable modules
  ray.home.modules = {
    apps = {
      wezterm.enable = true;
      discord.enable = true;
      kitty.enable = true;
      neovim.enable = true;
      telegram.enable = true;
      steam.enable = true;
      qbittorrent.enable = true;
      rofi.enable = true;
      waybar.enable = true;
    };
    shell = {
      fish.enable = true;
      zoxide.enable = true;
      bat.enable = true;
      eza.enable = true;
    };
    dev = {
      git.enable = true;
      tmux.enable = true;
      fzf.enable = true;
      ripgrep.enable = true;
      rust.enable = true;
      nodejs.enable = true;
      pyenv.enable = true;
    };
  };

  # Import modules
  imports = [
    ./modules/apps
    ./modules/shell
    ./modules/dev
    ./profiles
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = mkDotfiles {
    path = ".dotfiles";
    files = [
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
  };

  home.sessionPath = [ ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    bat
    fzf
    fastfetch
    git-repo
    luarocks
    nixd
    nodejs_22
    ripgrep
    rustup
    stow
    unzip
    zoxide
    git
    lazygit
    fzf
    zoxide
    tmux
    wezterm
    kitty
    rofi
    code-cursor
    discord
    telegram-desktop
    steam
    qbittorrent
    oh-my-fish
  ];

  # Programs configuration
  programs = {
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
        ls = "ls -ah --color";
        ll = "ls -lah --color";
      };
    };
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
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };
  };

  # Services configuration
  services = {
    syncthing = {
      enable = true;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
