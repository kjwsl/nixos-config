# Starship cross-shell prompt.
# Contributes to flake.modules.homeManager.base.
{...}: {
  flake.modules.homeManager.base = {...}: {
    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      settings = {
        "$schema" = "https://starship.rs/config-schema.json";
        add_newline = false;
        command_timeout = 1000;

        format = builtins.concatStringsSep "" [
          "$hostname"
          "$directory"
          "\n"
          "$localip"
          "$shlvl"
          "$singularity"
          "$kubernetes"
          "$vcsh"
          "$hg_branch"
          "$docker_context"
          "$package"
          "$custom"
          "\n"
          "$sudo"
          "\n"
          "$fill"
          "$git_branch"
          "$git_status"
          "$git_commit"
          "$cmd_duration"
          "$jobs"
          "$battery"
          "$time"
          "$status"
          "$os"
          "$container"
          "$shell"
          "$line_break"
          "$character"
        ];

        # ── Prompt character ──────────────────────────────────────────
        character = {
          success_symbol = "[ ](#6791C9 bold)";
          error_symbol = "[ ](#B66467 bold)";
        };

        line_break.disabled = false;

        fill = {
          symbol = " ";
          style = "bold green";
        };

        # ── Directory ─────────────────────────────────────────────────
        directory = {
          format = "[](fg:#252525 bg:none)[$path]($style)[█](fg:#232526 bg:#232526)[](fg:#6791C9 bg:#252525)[ ](fg:#252525 bg:#6791C9)[](fg:#6791C9 bg:none)";
          style = "fg:#E8E3E3 bg:#252525 bold";
          truncation_length = 3;
          truncate_to_repo = true;
          read_only = " 󰌾";
        };

        # ── Hostname ──────────────────────────────────────────────────
        hostname = {
          ssh_only = true;
          format = "[](fg:#252525 bg:none)[█](fg:#E8E3E3 bg:#252525)[$ssh_symbol$hostname](bold bg:#E8E3E3)[](fg:#E8E3E3 bg:none) ";
          disabled = false;
        };

        # ── Git ───────────────────────────────────────────────────────
        git_branch = {
          format = "[](fg:#252525 bg:none)[$branch]($style)[](fg:#252525 bg:#252525)[](fg:#81C19B bg:#252525)[](fg:#252525 bg:#81C19B)[](fg:#81C19B bg:none) ";
          style = "fg:#E8E3E3 bg:#252525";
          symbol = " ";
        };

        git_status = {
          format = "[](fg:#252525 bg:none)[$all_status$ahead_behind]($style)[](fg:#252525 bg:#252525)[](fg:#6791C9 bg:#252525)[ ](fg:#252525 bg:#6791C9)[](fg:#6791C9 bg:none) ";
          style = "fg:#E8E3E3 bg:#252525";
          conflicted = "=";
          ahead = "⇡\${count}";
          behind = "⇣\${count}";
          diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
          up_to_date = " 󰄸 ";
          untracked = "?\${count}";
          stashed = "";
          modified = "!\${count}";
          staged = "+\${count}";
          renamed = "»\${count}";
          deleted = " \${count}";
        };

        git_commit = {
          format = "[\\(\$hash\\)]($style) [\\(\$tag\\)]($style)";
          style = "green";
        };

        git_state = {
          format = "\\([$state( $progress_current/$progress_total)]($style)\\) ";
          style = "yellow";
          rebase = "REBASING";
          merge = "MERGING";
          revert = "REVERTING";
          cherry_pick = "CHERRY-PICKING";
          bisect = "BISECTING";
          am = "AM";
          am_or_rebase = "AM/REBASE";
        };

        # ── Command duration ──────────────────────────────────────────
        cmd_duration = {
          min_time = 1;
          format = "[](fg:#252525 bg:none)[$duration]($style)[](fg:#252525 bg:#252525)[](fg:#C397D8 bg:#252525)[󱑂 ](fg:#252525 bg:#C397D8)[](fg:#C397D8 bg:none)";
          disabled = false;
          style = "fg:#E8E3E3 bg:#252525 bold";
        };

        # ── Custom Modules ────────────────────────────────────────────
        custom.jj = {
          command = ''jj log -r @ --no-graph --ignore-working-copy -T 'separate(" ", change_id.shortest(8), if(bookmarks, bookmarks.join(" ")))' 2>/dev/null'';
          when = "jj root --ignore-working-copy 2>/dev/null";
          shell = ["sh"];
          symbol = "󱗆 ";
          style = "bold bright-magenta";
          format = "[$symbol$output]($style) ";
        };

        # ── Language Symbols (Merged) ─────────────────────────────────
        aws.symbol = "  ";
        conda.symbol = " ";
        dart.symbol = " ";
        docker_context = {
          symbol = " ";
          format = "via [\$symbol\$context]($style) ";
          style = "blue bold";
          only_with_files = true;
          detect_files = ["docker-compose.yml", "docker-compose.yaml", "Dockerfile"];
          disabled = false;
        };
        elixir.symbol = " ";
        elm.symbol = " ";
        golang.symbol = " ";
        hg_branch.symbol = " ";
        java.symbol = " ";
        julia.symbol = " ";
        haskell.symbol = "λ ";
        memory_usage.symbol = " ";
        nim.symbol = " ";
        nix_shell.symbol = " ";
        package.symbol = " ";
        perl.symbol = " ";
        php.symbol = " ";
        python = {
          symbol = " ";
          format = "via [\${symbol}python (\${version} )(\\(\$virtualenv\\) )]($style)";
          style = "bold yellow";
        };
        ruby.symbol = " ";
        rust.symbol = " ";
        scala.symbol = " ";
        shlvl.symbol = " ";
        swift.symbol = "ﯣ ";
        nodejs = {
          format = "via [ Node.js \$version](bold green) ";
          detect_files = ["package.json", ".node-version"];
          detect_folders = ["node_modules"];
        };

        # ── Disabled Modules (Noise reduction from TOML) ──────────────
        c.disabled = true;
        cmake.disabled = true;
        haskell.disabled = true;
        python.disabled = true;
        ruby.disabled = true;
        rust.disabled = true;
        perl.disabled = true;
        package.disabled = true;
        lua.disabled = true;
        nodejs.disabled = true;
        java.disabled = true;
        golang.disabled = true;
      };
    };
  };
}
