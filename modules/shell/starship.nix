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
        add_newline = true;
        command_timeout = 1000;

        format = builtins.concatStringsSep "" [
          "$username"
          "$hostname"
          "$nix_shell"
          "$directory"
          "\${custom.jj}"
          "$git_branch"
          "$git_state"
          "$git_status"
          "$c"
          "$golang"
          "$java"
          "$kotlin"
          "$lua"
          "$nodejs"
          "$python"
          "$rust"
          "$zig"
          "$docker_context"
          "$cmd_duration"
          "$line_break"
          "$character"
        ];

        # ── Prompt character ──────────────────────────────────────────
        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
          vimcmd_symbol = "[❮](bold green)";
        };

        # ── Directory ─────────────────────────────────────────────────
        directory = {
          truncation_length = 3;
          truncate_to_repo = true;
          style = "bold cyan";
          read_only = " 󰌾";
        };

        # ── SSH context (only visible in remote sessions) ─────────────
        username = {
          show_always = false;
          format = "[$user]($style)@";
          style_user = "bold green";
          style_root = "bold red";
        };

        hostname = {
          ssh_only = true;
          format = "[$hostname]($style) ";
          style = "bold green";
        };

        # ── Git ───────────────────────────────────────────────────────
        git_branch = {
          symbol = " ";
          format = "[$symbol$branch(:$remote_branch)]($style) ";
          style = "bold purple";
          truncation_length = 24;
        };

        git_status = {
          format = "([$all_status$ahead_behind]($style) )";
          style = "bold red";
        };

        git_state = {
          format = "\\([$state( $progress_current/$progress_total)]($style)\\) ";
          style = "bold yellow";
        };

        # ── Jujutsu (via custom module) ───────────────────────────────
        custom.jj = {
          command = ''jj log -r @ --no-graph --ignore-working-copy -T 'separate(" ", change_id.shortest(8), if(bookmarks, bookmarks.join(" ")))' 2>/dev/null'';
          when = "jj root --ignore-working-copy 2>/dev/null";
          shell = ["sh"];
          symbol = "󱗆 ";
          style = "bold bright-magenta";
          format = "[$symbol$output]($style) ";
        };

        # ── Nix shell ─────────────────────────────────────────────────
        nix_shell = {
          symbol = " ";
          format = "[$symbol$state( \\($name\\))]($style) ";
          style = "bold blue";
          heuristic = false;
          impure_msg = "[impure](bold red)";
          pure_msg = "[pure](bold green)";
          unknown_msg = "[unknown](bold yellow)";
        };

        # ── Command duration ──────────────────────────────────────────
        cmd_duration = {
          min_time = 2000;
          format = "[ $duration]($style) ";
          style = "bold yellow";
        };

        # ── Language toolchains (contextual, Nerd Font symbols) ───────
        python = {
          symbol = " ";
          format = "[$symbol($version )(\\($virtualenv\\) )]($style)";
          style = "bold yellow";
        };

        rust = {
          symbol = " ";
          format = "[$symbol($version )]($style)";
          style = "bold red";
        };

        nodejs = {
          symbol = " ";
          format = "[$symbol($version )]($style)";
          style = "bold green";
        };

        golang = {
          symbol = " ";
          format = "[$symbol($version )]($style)";
          style = "bold cyan";
        };

        lua = {
          symbol = " ";
          format = "[$symbol($version )]($style)";
          style = "bold blue";
        };

        # ── Docker ────────────────────────────────────────────────────
        docker_context = {
          symbol = " ";
          format = "[$symbol$context]($style) ";
          style = "bold blue";
        };

        # ── Disabled (noise reduction) ────────────────────────────────
        package.disabled = true;
      };
    };
  };
}
