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
  imports = [
    ./modules/apps
    ./modules/shell
    ./modules/dev
  ];

  # Basic configuration
  home.username = "ray";
  home.homeDirectory = homeDir;
  home.stateVersion = "24.11";

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

  # imports = [
  #   inputs.sops-nix.homeManagerModules.sops
  #   ./modules
  # ];

  # xdg.configFile = mkDotfiles {
  #   path = ".dotfiles/.config";
  #   files = [
  #     "clangd"
  #     "eza"
  #     "fish"
  #     "gh"
  #     "sops"
  #     "kitty"
  #     "lazygit"
  #     "nvim"
  #     "omf"
  #     "waybar"
  #     "wezterm"
  #     "zsh"
  #   ];
  # };

  # sops = {
  #   # It's also possible to use a ssh key, but only when it has no password:
  #   #age.sshKeyPaths = [ "/home/user/path-to-ssh-key" ];
  #   defaultSopsFile = ../sops/secrets/secrets.yaml;
  #   defaultSopsFormat = "yaml";
  #   age.keyFile = "${homeDir.content}/.config/sops/age/keys.txt"; # must have no password!

  #   secrets = {
  #     "omnivore_api_key" = {
  #       path = "${homeDir.content}/tmp/secrets.yaml";
  #     };
  #   };
  # };


  systemd.user.services.mbsync.Unit.After = [ "sops-nix.service" ];
  # systemd.user.services."myservice" = {
  #   script = ''
  #     #!/bin/sh
  #     echo "omnivore_api_key: ${config.sops.secrets.omnivore_api_key.key}"
  #   '';
  #   serviceConfig = {
  #     User = config.home.username;
  #     WorkingDirectory = "/var/lib/myservice";
  #   };
  # };

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
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

    # Development tools
    git
    lazygit
    fzf
    zoxide
    tmux
    wezterm
    kitty
    rofi
    code-cursor

    # Communication
    discord
    telegram-desktop

    # Entertainment
    steam
    qbittorrent

    # Shell
    oh-my-fish
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  # home.file = mkDotfiles
  #   {
  #     path = ".dotfiles";
  #     files = [
  #       ".aliasrc"
  #       ".bashrc"
  #       ".fonts"
  #       ".gitconfig"
  #       ".p10k.zsh"
  #       ".clang-format"
  #       ".zshrc"
  #       ".oh-my-bash"
  #       ".vst3"
  #       "images"
  #       "programs"
  #       "modules"
  #       "notes"
  #     ];
  #   };

  home.sessionPath = [


  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
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
    zsh = {
      initExtra = ''
        if [[ -f ~/.p10k.zsh ]]; then
            source ~/.p10k.zsh
        fi
      '';
      enableCompletion = true;
      autosuggestion.enable = true;
      autocd = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        v = "nvim";
      };
      history = {
        size = 10000;
        path = "${config.xdg.dataHome}/zsh/history";
      };
      zplug = {
        enable = true;
        plugins = [
          { name = "zsh-users/zsh-autosuggestions"; } # Simple plugin installation
          { name = "romkatv/powerlevel10k"; tags = [ "as:theme" "depth:1" ]; } # Installations with additional options. For the list of options, please refer to Zplug README.
          { name = "zsh-users/zsh-syntax-highlighting"; } # Installations with additional options. For the list of options, please refer to Zplug README.
          { name = "catppuccin/zsh-syntax-highlighting"; }
          { name = "zsh-users/zsh-autosuggestions"; }
          { name = "zsh-users/zsh-completions"; }
          { name = "zsh-users/zsh-history-substring-search"; }
          { name = "zsh-users/zsh-syntax-highlighting"; }
        ];
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

    gh = {
      # enable = true;
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
      };
      gitCredentialHelper.hosts = [
        "https://github.com"
        "https://gist.github.com"
      ];
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
      # plugins = with pkgs; [
      #         vimPlugins.nvim-treesitter
      #     	    vimPlugins.nvim-treesitter.withAllGrammars
      #     	    vimPlugins.nvim-treesitter-context
      #     	    vimPlugins.nvim-treesitter-refactor
      #     	    vimPlugins.nvim-treesitter-endwise
      #     	    vimPlugins.completion-treesitter
      #     	    luajitPackages.luarocks-build-treesitter-parser
      # ];
    };
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = "org.qutebrowser.qutebrowser.desktop";
    "x-scheme-handler/http" = "org.qutebrowser.qutebrowser.desktop";
    "x-scheme-handler/https" = "org.qutebrowser.qutebrowser.desktop";
    "x-scheme-handler/about" = "org.qutebrowser.qutebrowser.desktop";
    "x-scheme-handler/unknown" = "org.qutebrowser.qutebrowser.desktop";
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/ray/etc/profile.d/hm-session-vars.sh
  #

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Services configuration
  services = {
    # Enable syncthing
    syncthing = {
      enable = true;
    };
  };
}
