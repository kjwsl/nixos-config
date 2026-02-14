{ config, pkgs, ... }:

{
  # Fish shell configuration
  programs.fish = {
    enable = true;

    # Shell aliases from alias.fish
    shellAliases = {
      # Editor shortcuts
      v = "nvim";
      vim = "nvim";
      "v." = "nvim .";

      # Git
      g = "git";

      # Tree with colors
      tree = "tree -C";

      # Eza (modern ls)
      ls = "eza --icons --group-directories-first -a";
      ll = "eza --icons --group-directories-first -la";

      # Nix Helper (nh) - Modern unified operations
      hm-switch = "nh home switch";
      hm-build = "nh home build";
      nix-clean = "nh clean all --keep 3";
      nix-search = "nh search";

      # Performance benchmarking
      fish-bench = "time fish -i -c exit";

      # Reload fish config
      fish_reload = "source $__fish_config_dir/config.fish";
    };

    # Custom functions from functions.fish
    functions = {
      # Environment variable loader
      envsource = ''
        for line in (cat $argv | grep -v '^#')
          set item (string split -m 1 '=' $line)
          set -gx $item[1] $item[2]
        end
      '';

      # Pacman install helper
      pi = ''
        if type -q pacman
          sudo pacman -S --needed --noconfirm $argv
        end
      '';

      # Fuzzy file opener with nvim
      vf = ''
        nvim (fzf -m --preview 'bat --style=numbers --color=always {}')
      '';

      # Fuzzy directory jumper
      zf = ''
        set dir (find . -type d -print | fzf) || return
        z $dir
      '';

      # Smart dd function for flashing/wiping
      smartdd = {
        argumentNames = ["source" "dest"];
        body = ''
          # 1. Input Validation
          if test -z "$source"; or test -z "$dest"
            echo "Usage: smartdd <input_file_or_dev_zero> <destination_device>"
            return 1
          end

          if not test -e "$dest"
            echo "Error: Destination $dest does not exist."
            return 1
          end

          # 2. Variable Setup
          set bs_size "4M"
          set count_bytes 0
          set mode ""

          # 3. Determine Mode & Calculate Size
          if test "$source" = "/dev/zero"
            set mode "WIPE"
            if type -q lsblk
              set count_bytes (lsblk -b -n -o SIZE $dest | head -n 1)
            else
              set blocks (cat /proc/partitions | grep (basename $dest)\$ | awk '{print $3}')
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

          # 4. Safety Check & Confirmation
          if test "$count_bytes" -eq 0
            echo "Error: Could not determine size. Aborting."
            return 1
          end

          set size_human (math -s0 "$count_bytes / 1024 / 1024")
          echo "---------------------------------------------------"
          echo "Mode:      $mode"
          echo "Source:    $source"
          echo "Target:    $dest"
          echo "Data Size: $count_bytes bytes (~$size_human MB)"
          echo "---------------------------------------------------"
          read -P "Press [Enter] to start or [Ctrl+C] to cancel..." confirm

          # 5. Execution
          dd if="$source" of="$dest" bs=$bs_size count=$count_bytes iflag=count_bytes status=progress

          # 6. Final Sync
          echo "Syncing cache..."
          sync
          echo "Done."
        '';
      };

      # ntfy.sh notification helper
      notify = ''
        set -l msg (test (count $argv) -gt 0; and string join " " $argv; or echo "Task completed")
        set -l dir (string replace $HOME "~" $PWD)
        curl -s \
          -H "Title: 🔔 $hostname: Manual notification" \
          -d "$msg

Directory: $dir" \
          "ntfy.sh/$NTFY_TOPIC" >/dev/null 2>&1 &
      '';
    };

    # Fish plugins (Fisher plugins converted to home-manager)
    # Note: Some plugins omitted for now due to hash issues
    # You can install them manually with Fisher or we can add correct hashes later
    plugins = [
      # Nix environment support
      {
        name = "nix-env";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "00c6cc762427efe08ac0bd0d1b1d12048d3ca727";
          sha256 = "1hrl22dd0aaszdanhvddvqz3aq40jp9zi2zn0v1hjnf7fx4bgpma";
        };
      }

      # Bass - run bash utilities in fish
      {
        name = "bass";
        src = pkgs.fetchFromGitHub {
          owner = "edc";
          repo = "bass";
          rev = "2fd3d2157d5271ca3575b13daec975ca4c10577a";
          sha256 = "0mb01y1d0g8ilsr5m8a71j6xmqlyhf8w4xjf00wkk8k41cz3ypky";
        };
      }

      # TODO: Add more plugins with correct hashes:
      # - done (notifications)
      # - puffer-fish (text expansion)
      # - sponge (clean history)
      # - fish-abbreviation-tips
      # - fzf.fish (FZF integration)
      # - plugin-git
    ];

    # Interactive shell initialization (from config.fish)
    interactiveShellInit = ''
      # Disable fish greeting
      set -g fish_greeting

      # Core settings
      set -gx EDITOR "nvim"
      set -gx VISUAL $EDITOR

      # Theme - Catppuccin Mocha
      fish_config theme choose "Catppuccin Mocha"

      # Enable transient prompt
      set -g fish_transient_prompt 1

      # Paths
      set -gx PATH "$HOME/.local/bin" $PATH
      fish_add_path "$HOME/.rustup/toolchains/stable-aarch64-apple-darwin/bin/"
      fish_add_path "$HOME/.cargo/bin/"
      set -gx PKG_CONFIG_PATH "$HOME/.luarocks/share/lua/5.1:$HOME/.nix-profile/bin:$HOME/.local/lib/pkgconfig:$PKG_CONFIG_PATH"

      # Mise - Modern development environment manager
      # Activates mise shims and environment variables
      if type -q mise
        mise activate fish | source
      end

      # Nix Helper (nh) - Modern unified CLI for Nix operations
      set -gx FLAKE "$HOME/repos/home-manager"
      set -gx NH_NOM 1  # Enable nix-output-monitor by default

      # Environment Loading
      if test -f $HOME/.envrc
        bass source $HOME/.envrc
      end

      if test -d $HOME/modules
        for file in $HOME/modules/*.sh
          bass source $file
        end
      end

      # Initialize starship (handled by programs.starship)
      # Initialize zoxide (handled by programs.zoxide)

      # Zoxide + FZF helper
      alias zo="z (dirname (fzf))"

      # Secrets and Work
      if test -f $HOME/.secrets
        bass source $HOME/.secrets
      end

      if test -f $HOME/work.fish
        source $HOME/work.fish
      end

      # Vi key bindings
      fish_vi_key_bindings

      # ntfy.sh topic
      set -gx NTFY_TOPIC notify-3152210757

      # Key bindings
      bind \cf zf  # Ctrl+F for fuzzy directory jump
    '';
  };

  # Zoxide - Smart directory jumper
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  # FZF - Fuzzy finder
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  # Atuin - Shell history with sync support
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "https://api.atuin.sh";
      search_mode = "fuzzy";
    };
  };
}
