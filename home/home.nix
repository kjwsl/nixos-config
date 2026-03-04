{
  config,
  lib,
  pkgs,
  catppuccin,
  ...
}:
let
  isDarwin = lib.darwin.isDarwin;
in
{
  home.packages = with pkgs; [
    # frawk
    # termscp
    #loop
    alejandra # Nix code formatter
    amazon-q-cli
    atuin
    bat
    bitwarden-cli
    bottom
    broot
    btop
    cachix
    cargo-watch
    chezmoi
    choose
    clang-tools
    cmake
    delta
    difftastic
    dust
    eva
    eza
    fastfetch
    fd
    fselect
    fzf
    gcc
    gh
    starship
    git
    git-absorb
    gitoxide
    gitui
    glow
    gpg-tui
    hexyl
    httm
    hyperfine
    jujutsu
    just
    lazygit
    lazyjj
    lemmeknow
    lsd
    mcfly
    mise
    mprocs # Run multiple processes in parallel
    navi
    neovim
    nh
    nil # Nix LSP
    ninja
    ouch
    procs
    ripgrep
    ripgrep-all
    rm-improved # Remove files with confirmation
    rnr # Rename files with confirmation
    runiq # Remove duplicate lines
    ruplacer
    rust-parallel
    rustup
    scout # URL fuzzy finder
    sd
    silver-searcher # Fuzzy finder
    skim # Fuzzy finder
    so # Ask questions on StackOverflow https://github.com/samtay/so
    tealdeer # tldr tlrc
    tere
    tmux
    tokei # Count your code with extra features like language support
    tre-command
    tree
    trippy

    # Python Tool Suite
    uv

    vaultwarden

    xcp
    xh
    xxh

    # File Explorer
    yazi

    # Terminal Multiplexer
    zellij
    zig
    zoxide
  ];

  programs = {
    uv = {
      enable = true;
      settings = {
        python-preference = "managed";
      };
    };

    direnv = {
      enable = true;

      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;

      mise.enable = true;
    };

    television = {
      enable = true;

      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };

    nix-search-tv.enableTelevisionIntegration = true;

    zoxide = {
      enable = true;

      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };

    nushell = {
      enable = true;

      extraConfig = ''
        # Add nix profile to PATH
                    $env.PATH ++= [ "~/.nix-profile/bin" ]
      '';

      shellAliases = {
        "v." = "nvim .";
        v = "nvim";
      };

      plugins = with pkgs.nushellPlugins; [
        formats
        skim
        semver
        highlight
        gstat
        query
      ];
    };

    carapace = {
      enable = true;

      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };

    fish = {
      enable = true;

      shellAliases = {
        tree = "tree -C";
        v = "nvim";
        "v." = "nvim .";
        g = "git";
        fish-bench = "time fish -i -c exit";
        fish_reload = "source $__fish_config_dir/config.fish";
        zo = "z (dirname (fzf))";
        ls = "eza --icons --group-directories-first -a";
        ll = "eza --icons --group-directories-first -la";
      };

      functions = {
        vf = {
          body = "nvim (fzf -m --preview 'bat --style=numbers --color=always {}')";
        };

        zf = {
          body = ''
            set dir (find . -type d -print | fzf) || return
            z $dir
          '';
        };

        envsource = {
          body = ''
            for line in (cat $argv | grep -v '^#')
              set item (string split -m 1 '=' $line)
              set -gx $item[1] $item[2]
            end
          '';
        };

        pi = {
          body = ''
            if type -q pacman
              sudo pacman -S --needed --noconfirm $argv
            end
          '';
        };

        notify = {
          body = ''
            set -l msg (test (count $argv) -gt 0; and string join " " $argv; or echo "Task completed")
            set -l dir (string replace $HOME "~" $PWD)
            curl -s \
                -H "Title: 🔔 $hostname: Manual notification" \
                -d "$msg

Directory: $dir" \
                "ntfy.sh/$NTFY_TOPIC" >/dev/null 2>&1 &
          '';
        };

        __notify_on_long_command = {
          onEvent = "fish_postexec";
          body = ''
            set -l command_name (string split -m 1 " " $argv[1])[1]
            if contains $command_name nvim vi vim ssh hx btop
              return
            end
            if test $CMD_DURATION -gt 30000
              set -l secs (math "$CMD_DURATION / 1000")
              set -l status_emoji (test $status -eq 0 && echo "✅" || echo "❌")
              set -l status_text (test $status -eq 0 && echo "Success" || echo "Failed (exit $status)")
              set -l cmd (string shorten -m 100 "$argv[1]")
              set -l dir (string replace $HOME "~" $PWD)
              set -l host $hostname
              curl -s \
                  -H "Title: $status_emoji $host: Command finished" \
                  -d "$cmd

Status: $status_text
Duration: $secs seconds
Directory: $dir" \
                  "ntfy.sh/$NTFY_TOPIC" >/dev/null 2>&1 &
            end
          '';
        };

        smartdd = {
          body = ''
            set -l source $argv[1]
            set -l dest $argv[2]

            if test -z "$source"; or test -z "$dest"
              echo "Usage: smartdd <input_file_or_dev_zero> <destination_device>"
              return 1
            end
            if not test -e "$dest"
              echo "Error: Destination $dest does not exist."
              return 1
            end

            set -l bs_size "4M"
            set -l count_bytes 0
            set -l mode ""

            if test "$source" = "/dev/zero"
              set mode "WIPE"
              if type -q lsblk
                set count_bytes (lsblk -b -n -o SIZE $dest | head -n 1)
              else
                set -l blocks (cat /proc/partitions | grep (basename $dest)\$ | awk '{print $3}')
                if test -n "$blocks"
                  set count_bytes (math "$blocks * 1024")
                end
              end
            else
              set mode "FLASH"
              if not test -e "$source"
                echo "Error: Source file $source not found."
                return 1
              end
              if type -q stat
                if stat --version > /dev/null 2>&1
                  set count_bytes (stat -c %s "$source")
                else
                  set count_bytes (stat -f %z "$source")
                end
              else
                echo "Error: 'stat' command missing. Cannot calculate file size."
                return 1
              end
            end

            if test "$count_bytes" -eq 0
              echo "Error: Could not determine size. Aborting."
              return 1
            end

            set -l size_human (math -s0 "$count_bytes / 1024 / 1024")
            echo "---------------------------------------------------"
            echo "Mode:      $mode"
            echo "Source:    $source"
            echo "Target:    $dest"
            echo "Data Size: $count_bytes bytes (~$size_human MB)"
            echo "---------------------------------------------------"
            read -P "Press [Enter] to start or [Ctrl+C] to cancel..." confirm

            dd if="$source" of="$dest" bs=$bs_size count=$count_bytes iflag=count_bytes status=progress
            echo "Syncing cache..."
            sync
            echo "Done."
          '';
        };
      };

      interactiveShellInit = ''
        set -g fish_greeting
        set -g fish_transient_prompt 1
        set -gx EDITOR nvim
        set -gx VISUAL $EDITOR
        set -gx NTFY_TOPIC notify-3152210757

        # Mise activation
        if type -q mise
          mise activate fish | source
        end

        # Paths
        fish_add_path "$HOME/.local/bin"
        fish_add_path "$HOME/.rustup/toolchains/stable-aarch64-apple-darwin/bin/"
        fish_add_path "$HOME/.cargo/bin/"
        set -gx PKG_CONFIG_PATH "$HOME/.luarocks/share/lua/5.1:$HOME/.nix-profile/bin:$HOME/.local/lib/pkgconfig:$PKG_CONFIG_PATH"

        # Environment loading via bass
        if test -f $HOME/.envrc
          bass source $HOME/.envrc
        end
        if test -d $HOME/modules
          for file in $HOME/modules/*.sh
            bass source $file
          end
        end
        if test -f $HOME/.secrets
          bass source $HOME/.secrets
        end
        if test -f $HOME/work.fish
          source $HOME/work.fish
        end

        # Vi key bindings + custom
        fish_vi_key_bindings
        bind \cf zf

        # Starship prompt
        if type -q starship
          starship init fish | source
        end

        # Neural Orchestrator context
        if test -d $HOME/.context/integrations/fish
          set -p fish_function_path $HOME/.context/integrations/fish
          if test -f $HOME/.context/integrations/fish/gemini-profiles.fish
            source $HOME/.context/integrations/fish/gemini-profiles.fish
          end
        end
      '';

      plugins = [
        { name = "bass"; src = pkgs.fishPlugins.bass; }
        { name = "done"; src = pkgs.fishPlugins.done; }
        { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish; }
        { name = "plugin-git"; src = pkgs.fishPlugins.plugin-git; }
        { name = "puffer"; src = pkgs.fishPlugins.puffer; }
        { name = "sponge"; src = pkgs.fishPlugins.sponge; }
        { name = "spark"; src = pkgs.fishPlugins.spark; }
        {
          name = "nix-env.fish";
          src = builtins.fetchTarball {
            url = "https://github.com/lilyball/nix-env.fish/archive/refs/heads/master.tar.gz";
            sha256 = "069ybzdj29s320wzdyxqjhmpm9ir5815yx6n522adav0z2nz8vs4";
          };
        }
        {
          name = "replay.fish";
          src = builtins.fetchTarball {
            url = "https://github.com/jorgebucaran/replay.fish/archive/refs/heads/main.tar.gz";
            sha256 = "1n2xji4w5k1iyjsvnwb272wx0qh5jfklihqfz0h1a1bd3zp3sd2g";
          };
        }
        {
          name = "fish-abbreviation-tips";
          src = builtins.fetchTarball {
            url = "https://github.com/gazorby/fish-abbreviation-tips/archive/refs/heads/master.tar.gz";
            sha256 = "05b5qp7yly7mwsqykjlb79gl24bs6mbqzaj5b3xfn3v2b7apqnqp";
          };
        }
      ];
    };

    # Custom Prompt
    # starship = {
    #   enable = true;
    #   settings = {
    #     add_newline = true;
    #     character = {
    #       success_symbol = "[➜](bold green)";
    #       error_symbol = "[➜](bold red)";
    #     };
    #   };

    #   enableBashIntegration = true;
    #   enableZshIntegration = true;
    #   enableFishIntegration = true;
    #   enableNushellIntegration = true;
    #
    #   enableTransience = true;
    # };

    #   vivid = {
    #     enable = true;
    #     themes = {
    #       mocha = builtins.fetchurl {
    #         url = "https://raw.githubusercontent.com/NearlyTRex/Vivid/refs/heads/master/themes/catppuccin-mocha.yml";
    #         sha256 = "sha256:1hfwaf8lfq32w9vcdlbwrq5hwwz725i7icavg6qs66awpzqqb34k";
    #       };
    #     };
    #
    #     activeTheme = "mocha";
    #
    #     enableBashIntegration = true;
    #     enableZshIntegration = true;
    #     enableFishIntegration = true;
    #     enableNushellIntegration = true;
    #   };
    # };
    # };
  };

  catppuccin = {
    enable = true;
    flavor = "mocha";

    atuin.enable = true;
    bat.enable = true;
    bottom.enable = true;
    broot.enable = true;
    btop.enable = true;
    delta.enable = true;
    eza.enable = true;
    fish.enable = true;
    fzf.enable = true;
    gemini-cli.enable = true;
    ghostty.enable = true;
    helix.enable = true;
    nushell.enable = true;
    skim.enable = true;
    starship.enable = true;
    lazygit.enable = true;
    lsd.enable = true;
    television.enable = true;
    thunderbird.enable = true;
    yazi.enable = true;
    zed.enable = true;
    zellij.enable = true;
  };

  home.stateVersion = "25.05";
}
