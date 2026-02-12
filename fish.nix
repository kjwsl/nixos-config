{ config, pkgs, lib, ... }:

{
  programs.fish = {
    enable = true;

    # Shell initialization (runs for all shells)
    shellInit = ''
      # pnpm
      set -gx PNPM_HOME "$HOME/Library/pnpm"
      if not string match -q -- $PNPM_HOME $PATH
        set -gx PATH "$PNPM_HOME" $PATH
      end
    '';

    # Interactive shell initialization
    interactiveShellInit = ''
      # Disable greeting message
      set -g fish_greeting

      # Core settings
      set -gx EDITOR "nvim"
      set -gx VISUAL $EDITOR

      # Mise activation
      if type -q mise
        mise activate fish | source
      end

      # Theme - Explicitly use dark mode variant
      fish_config theme choose "Catppuccin Mocha" --color-theme=dark

      # Enable transient prompt
      set -g fish_transient_prompt 1

      # Paths
      set -gx PATH "$HOME/.local/bin" $PATH
      fish_add_path "$HOME/.rustup/toolchains/stable-aarch64-apple-darwin/bin/"
      fish_add_path "$HOME/.cargo/bin/"
      set -gx PKG_CONFIG_PATH "$HOME/.luarocks/share/lua/5.1:$HOME/.nix-profile/bin:$HOME/.local/lib/pkgconfig:$PKG_CONFIG_PATH"

      # Load Aliases
      if test -f $__fish_config_dir/alias.fish
        source $__fish_config_dir/alias.fish
      end

      # Load Functions
      if test -f $__fish_config_dir/functions.fish
        source $__fish_config_dir/functions.fish
      end

      # Environment Loading
      if test -f $HOME/.envrc
        bass source $HOME/.envrc
      end

      if test -d $HOME/modules
        for file in $HOME/modules/*.sh
          bass source $file
        end
      end

      # Starship initialization
      if type -q starship
        starship init fish | source
      end

      # Initialize zoxide (fallback if plugin fails)
      if type -q zoxide
        zoxide init fish | source
      end

      # Vi key bindings
      fish_vi_key_bindings

      # ntfy.sh notifications
      set -gx NTFY_TOPIC notify-3152210757

      # Neural Orchestrator Context Integration
      # Dynamically add the Context Vault's function library if it exists
      if test -d $HOME/.context/integrations/fish
        set -p fish_function_path $HOME/.context/integrations/fish
        # Only source if the file actually exists
        if test -f $HOME/.context/integrations/fish/gemini-profiles.fish
          source $HOME/.context/integrations/fish/gemini-profiles.fish
        end
      end

      # Secrets and Work
      if test -f $HOME/.secrets
        bass source $HOME/.secrets
      end

      if test -f $HOME/work.fish
        source $HOME/work.fish
      end

      # OpenClaw Completion
      if test -f "$HOME/.openclaw/completions/openclaw.fish"
        source "$HOME/.openclaw/completions/openclaw.fish"
      end

      # Key bindings from alias.fish.backup
      bind \cf zf
    '';

    # Shell aliases
    shellAliases = {
      fish_reload = "source $__fish_config_dir/config.fish";
      zo = "z (dirname (fzf))";
      ls = "eza --icons --group-directories-first -a";
      ll = "eza --icons --group-directories-first -la";

      # From alias.fish.backup
      tree = "tree -C";
      v = "nvim";
      "v." = "nvim .";
      g = "git";
      fish-bench = "time fish -i -c exit";
    };

    # Custom functions
    functions = {
      notify = ''
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
          # Skip for interactive editors and common long-running interactive tools
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

      # From alias.fish.backup
      vf = ''
        nvim (fzf -m --preview 'bat --style=numbers --color=always {}')
      '';

      zf = ''
        set dir (find . -type d -print | fzf) || return
        z $dir
      '';

      # From functions.fish.backup
      envsource = ''
        for line in (cat $argv | grep -v '^#')
          set item (string split -m 1 '=' $line)
          set -gx $item[1] $item[2]
        end
      '';

      pi = ''
        if type -q pacman
          sudo pacman -S --needed --noconfirm $argv
        end
      '';

      smartdd = ''
        # 1. Input Validation
        if test -z "$argv[1]"; or test -z "$argv[2]"
          echo "Usage: smartdd <input_file_or_dev_zero> <destination_device>"
          return 1
        end

        set source $argv[1]
        set dest $argv[2]

        if not test -e "$dest"
          echo "Error: Destination $dest does not exist."
          return 1
        end

        # 2. Variable Setup
        set bs_size "4M" # Optimal speed for most modern drives
        set count_bytes 0
        set mode ""

        # 3. Determine Mode & Calculate Size
        if test "$source" = "/dev/zero"
          # MODE: Zero Wipe
          # We need the size of the DESTINATION drive to know when to stop.
          set mode "WIPE"

          # Try lsblk first (Linux standard)
          if type -q lsblk
            set count_bytes (lsblk -b -n -o SIZE $dest | head -n 1)
          else
            # Fallback for Git Bash / MSYS (Parsing /proc/partitions)
            # Finds the block count and multiplies by 1024 to get bytes
            set blocks (cat /proc/partitions | grep (basename $dest)\$ | awk '{print $3}')
            if test -n "$blocks"
              set count_bytes (math "$blocks * 1024")
            end
          end
        else
          # MODE: Flash Image
          # We need the size of the INPUT file.
          set mode "FLASH"

          if not test -e "$source"
            echo "Error: Source file $source not found."
            return 1
          end

          # Get file size (stat -c %s is standard Linux; stat -f %z is BSD/Mac)
          if type -q stat
            # Check if we are on Linux/GitBash or Mac
            if stat --version > /dev/null 2>&1
              set count_bytes (stat -c %s "$source") # GNU/Linux
            else
              set count_bytes (stat -f %z "$source") # BSD/Mac
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
        # iflag=count_bytes: The secret sauce. Allows 'count' to be precise bytes
        # while keeping 'bs' large for speed.
        dd if="$source" of="$dest" bs=$bs_size count=$count_bytes iflag=count_bytes status=progress

        # 6. Final Sync
        echo "Syncing cache..."
        sync
        echo "Done."
      '';
    };

    plugins = [
      # Nix environment support for Fish shell
      {
        name = "nix-env-fish";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
          sha256 = "sha256-RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
        };
      }

      # Zoxide integration for Fish
      {
        name = "zoxide-fish";
        src = pkgs.fetchFromGitHub {
          owner = "kidonng";
          repo = "zoxide.fish";
          rev = "bfd5947bcc7cd01beb23c6a40ca9807c174bba0e";
          sha256 = "sha256-Hq9UXB99kmbWKUVFDeJL790P8ek+xZR7vlHUZo6DataE=";
        };
      }

      # Bass - use bash utilities in fish shell
      {
        name = "bass";
        src = pkgs.fetchFromGitHub {
          owner = "edc";
          repo = "bass";
          rev = "2fd3d2157d5271ca3575b13daec975ca4c10577a";
          sha256 = "sha256-fl4/Pgtkojk5AE52wpGDnuLajQxHoVqyphE90IIPYFU=";
        };
      }

      # Replay - run bash commands in fish shell
      {
        name = "replay";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "replay.fish";
          rev = "b5d032108f6fef9fb49eae7fb5c9ffc1f2d38b13";
          sha256 = "sha256-SvT6UxrviDONf/Fs7MfNMEWKJhWKdLVHAEo/54nZAGc=";
        };
      }

      # Spark - sparkline generator for fish
      {
        name = "spark";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "spark.fish";
          rev = "e22eb1e7a0528e4a0bce7b6dc502e2c2e4a99039";
          sha256 = "sha256-aeUjnFFAd6DsltlWeXXSU+W1RtN+dXlS/bKqGJNUWSE=";
        };
      }

      # Done - automatically receive notifications when long processes finish
      {
        name = "done";
        src = pkgs.fetchFromGitHub {
          owner = "franciscolourenco";
          repo = "done";
          rev = "fa906f5e8a8e959319b637d6477f2cb9c9f87b95";
          sha256 = "sha256-7flYZ0x/HmHQEiqhh7Y91k/ZvdW+Q2VazTzvhhmYf2g=";
        };
      }

      # Catppuccin theme for fish
      {
        name = "catppuccin-fish";
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "fish";
          rev = "0ce27b518e8ead555dec34dd8be3df5bd75cff8e";
          sha256 = "sha256-Dc/zdxfzAUM5NX8PxzfljRbYvO9f9syuLO8yBr+R3qg=";
        };
      }

      # Git plugin with useful aliases and functions
      {
        name = "plugin-git";
        src = pkgs.fetchFromGitHub {
          owner = "jhillyerd";
          repo = "plugin-git";
          rev = "8863b25ae9525e8b22910fba70a8c9230df695f5";
          sha256 = "sha256-EQKb1VqVw+CjDpJDNKPuWx//e/Y3bMN9YaSSVwkLSJ4=";
        };
      }

      # Puffer Fish - text expansion for fish
      {
        name = "puffer-fish";
        src = pkgs.fetchFromGitHub {
          owner = "nickeb96";
          repo = "puffer-fish";
          rev = "12d062eae0ad24f4ec20593be845ac30cd4b5923";
          sha256 = "sha256-2niYj0NLfmVIQguuGTA7RrPIcorJEPkxhH6Dhcy+6Bk=";
        };
      }

      # Sponge - clean up failed commands from history
      {
        name = "sponge";
        src = pkgs.fetchFromGitHub {
          owner = "meaningful-ooo";
          repo = "sponge";
          rev = "d5377f8fef7f87f0da99d1e7a7ae1d8c0ad492c5";
          sha256 = "sha256-04k8V/GVZTXL5ilz6Jh7wEb6FSII6bwsvlQEPVxfZGc=";
        };
      }

      # Fish abbreviation tips - hints for available abbreviations
      {
        name = "fish-abbreviation-tips";
        src = pkgs.fetchFromGitHub {
          owner = "gazorby";
          repo = "fish-abbreviation-tips";
          rev = "8ed76a62bb044ba4ad8e3e6832640178880df485";
          sha256 = "sha256-F1t81VliD+v6WEWqj1c1ehFBXzqLyumx5vV46s/FZRU=";
        };
      }

      # FZF integration for fish
      {
        name = "fzf-fish";
        src = pkgs.fetchFromGitHub {
          owner = "PatrickF1";
          repo = "fzf.fish";
          rev = "8c7e8fedacb86c9b7bf6e63c8e1ea1f9be52c35c";
          sha256 = "sha256-hVuXMJ0JdBRPd7Y+JGZhMjNM0lFLBsDQY08tZYchM8o=";
        };
      }
    ];
  };
}
