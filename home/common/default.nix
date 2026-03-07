# Shared Home Manager configuration.
# Contains the bulk of the user environment: shells, CLI tools, programs, and theming.
# This is a direct extraction / reorganisation of the previous monolithic home/home.nix.
{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # ── Nix tooling ──────────────────────────────────────────────────────────────
    alejandra
    cachix
    nh
    nil

    # ── Shell & terminal utilities ───────────────────────────────────────────────
    atuin
    bat
    broot
    btop
    choose
    delta
    difftastic
    dust
    eva
    eza
    fastfetch
    fd
    fselect
    fzf
    glow
    hexyl
    httm
    hyperfine
    jujutsu
    just
    lemmeknow
    lsd
    mcfly
    mprocs
    navi
    ouch
    procs
    ripgrep
    ripgrep-all
    rm-improved
    rnr
    runiq
    ruplacer
    rust-parallel
    rust-script
    sd
    silver-searcher
    skim
    so
    tealdeer
    tere
    tmux
    tokei
    tre-command
    tree
    trippy
    xcp
    xh
    xxh
    yazi
    zellij
    zoxide

    # ── Version control ──────────────────────────────────────────────────────────
    git
    git-absorb
    gitoxide
    gitui
    lazygit
    lazyjj
    gh
    gpg-tui

    # ── Development ──────────────────────────────────────────────────────────────
    clang-tools
    cmake
    gcc
    neovim
    ninja
    openssh
    rustup
    zig

    # ── Python ───────────────────────────────────────────────────────────────────
    uv

    # ── Secrets ──────────────────────────────────────────────────────────────────
    bitwarden-cli
    vaultwarden

    # ── Misc ─────────────────────────────────────────────────────────────────────
    amazon-q-cli
    chezmoi
    starship
  ];

  programs = {
    uv = {
      enable = true;
      settings.python-preference = "managed";
    };

    mise = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };

    bottom.enable = true;

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
        $env.PATH ++= [ "~/.nix-profile/bin" "/nix/var/nix/profiles/default/bin" ]
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
        vf.body = "nvim (fzf -m --preview 'bat --style=numbers --color=always {}')";
        zf.body = ''
          set dir (find . -type d -print | fzf) || return
          z $dir
        '';
        envsource.body = ''
          for line in (cat $argv | grep -v '^#')
            set item (string split -m 1 '=' $line)
            set -gx $item[1] $item[2]
          end
        '';
        pi.body = ''
          if type -q pacman
            sudo pacman -S --needed --noconfirm $argv
          end
        '';
        notify.body = ''
          set -l msg (test (count $argv) -gt 0; and string join " " $argv; or echo "Task completed")
          set -l dir (string replace $HOME "~" $PWD)
          curl -s \
              -H "Title: 🔔 $hostname: Manual notification" \
              -d "$msg

          Directory: $dir" \
              "ntfy.sh/$NTFY_TOPIC" >/dev/null 2>&1 &
        '';
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
        smartdd.body = ''
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
      interactiveShellInit = ''
        set -g fish_greeting
        set -g fish_transient_prompt 1
        set -gx EDITOR nvim
        set -gx VISUAL $EDITOR
        set -gx NTFY_TOPIC notify-3152210757

        # Mise activation (cached to avoid ~300ms penalty each start)
        if type -q mise
          set -l _mise_cache "$HOME/.cache/fish/mise_init.fish"
          set -l _mise_bin (command -s mise)
          if not test -f $_mise_cache; or test $_mise_bin -nt $_mise_cache
            mkdir -p (dirname $_mise_cache)
            mise activate fish >$_mise_cache
          end
          source $_mise_cache
        end

        # Paths
        fish_add_path "$HOME/.local/bin"
        fish_add_path "$HOME/.cargo/bin/"
        set -gx PKG_CONFIG_PATH "$HOME/.nix-profile/bin:$HOME/.local/lib/pkgconfig:$PKG_CONFIG_PATH"

        # Vi key bindings + custom
        fish_vi_key_bindings
        bind \cf zf

        # Starship prompt (cached to avoid ~110ms penalty each start)
        if type -q starship
          set -l _starship_cache "$HOME/.cache/fish/starship_init.fish"
          set -l _starship_bin (command -s starship)
          if not test -f $_starship_cache; or test $_starship_bin -nt $_starship_cache
            mkdir -p (dirname $_starship_cache)
            starship init fish >$_starship_cache
          end
          source $_starship_cache
        end
      '';
      plugins =
        [
          {
            name = "bass";
            src = pkgs.fishPlugins.bass;
          }
          {
            name = "plugin-git";
            src = pkgs.fishPlugins.plugin-git;
          }
          {
            name = "puffer";
            src = pkgs.fishPlugins.puffer;
          }
          {
            name = "sponge";
            src = pkgs.fishPlugins.sponge;
          }
          {
            name = "spark";
            src = pkgs.fishPlugins.spark;
          }
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
        ]
        ++ lib.optionals (!pkgs.stdenv.isDarwin) [
          {
            name = "fzf-fish";
            src = pkgs.fishPlugins.fzf-fish;
          }
        ];
    };
  };
}
