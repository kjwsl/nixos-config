{ config, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in
{
  # ============================================================================
  # Fish Shell
  # ============================================================================
  programs.fish = {
    enable = true;

    # Shell aliases (cross-platform)
    shellAliases = {
      # Editor shortcuts
      v = "nvim";
      "v." = "nvim .";

      # Git shortcuts
      g = "git";

      # Reload fish config
      fish_reload = "source $__fish_config_dir/config.fish";

      # Performance benchmarking
      fish-bench = "time fish -i -c exit";

      # Enhanced ls with eza (if available, fallback handled in fish)
      ls = "eza --icons --group-directories-first -a";
      ll = "eza --icons --group-directories-first -la";

      # Tree with colors
      tree = "tree -C";
    };

    # Fish-specific config
    interactiveShellInit = ''
      # Disable greeting message
      set -g fish_greeting

      # Enable transient prompt
      set -g fish_transient_prompt 1

      # Vi key bindings
      fish_vi_key_bindings

      # Theme - Catppuccin Mocha (managed by catppuccin.nix)
      fish_config theme choose "Catppuccin Mocha" --color-theme=dark

      # Mise activation (if available)
      if type -q mise
          mise activate fish | source
      end

      # Starship prompt (if available)
      if type -q starship
          starship init fish | source
      end

      # Zoxide integration (if available, fallback to plugin)
      if type -q zoxide
          zoxide init fish | source
      end

      # Enhanced zoxide alias
      alias zo="z (dirname (fzf))"

      # Load local/work-specific configs (not managed by Nix)
      if test -f $HOME/.secrets
          bass source $HOME/.secrets
      end

      if test -f $HOME/work.fish
          source $HOME/work.fish
      end

      # Load custom functions from dotfiles repo
      if test -f ${config.home.homeDirectory}/repos/home-manager/dotfiles/fish/functions.fish
          source ${config.home.homeDirectory}/repos/home-manager/dotfiles/fish/functions.fish
      end

      # ntfy.sh auto-notifications for long-running commands
      set -gx NTFY_TOPIC notify-3152210757

      function notify
          set -l msg (test (count $argv) -gt 0; and string join " " $argv; or echo "Task completed")
          set -l dir (string replace $HOME "~" $PWD)
          curl -s \
              -H "Title: 🔔 $hostname: Manual notification" \
              -d "$msg

      Directory: $dir" \
              "ntfy.sh/$NTFY_TOPIC" >/dev/null 2>&1 &
      end

      # Auto-notify for commands taking longer than 30 seconds
      function __notify_on_long_command --on-event fish_postexec
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
      end

      # Neural Orchestrator Context Integration
      if test -d $HOME/.context/integrations/fish
          set -p fish_function_path $HOME/.context/integrations/fish
          if test -f $HOME/.context/integrations/fish/gemini-profiles.fish
              source $HOME/.context/integrations/fish/gemini-profiles.fish
          end
      end

      # Custom functions defined inline
      function vf
          nvim (fzf -m --preview 'bat --style=numbers --color=always {}')
      end

      function zf
          set dir (find . -type d -print | fzf) || return
          z $dir
      end

      # Key bindings
      bind \cf zf
    '';

    # Fish plugins (managed by home-manager, not fisher)
    plugins = [
      # Add fish plugins here if needed
      # { name = "plugin-name"; src = pkgs.fishPlugins.plugin-name; }
    ];
  };

  # ============================================================================
  # Nushell
  # ============================================================================
  programs.nushell = {
    enable = true;

    # Environment variables (moved from home.nix)
    environmentVariables = {
      # Already handled in home.nix extraConfig
    };

    # Shell aliases
    shellAliases = {
      "v." = "nvim .";
      v = "nvim";
      g = "git";
    };

    # Nushell config is already in home.nix, keep it there for now
    # We'll migrate more specific nushell config here later if needed
  };

  # ============================================================================
  # Bash (minimal, for compatibility)
  # ============================================================================
  programs.bash = {
    enable = true;

    shellAliases = {
      v = "nvim";
      "v." = "nvim .";
      g = "git";
      ls = "eza --icons --group-directories-first -a";
      ll = "eza --icons --group-directories-first -la";
      tree = "tree -C";
    };

    initExtra = ''
      # Vi mode
      set -o vi

      # Load local/work-specific configs
      [ -f "$HOME/.secrets" ] && source "$HOME/.secrets"
      [ -f "$HOME/.bash_local" ] && source "$HOME/.bash_local"
    '';
  };

  # ============================================================================
  # Zsh (minimal, for compatibility)
  # ============================================================================
  programs.zsh = {
    enable = true;

    shellAliases = {
      v = "nvim";
      "v." = "nvim .";
      g = "git";
      ls = "eza --icons --group-directories-first -a";
      ll = "eza --icons --group-directories-first -la";
      tree = "tree -C";
    };

    initContent = ''
      # Vi mode
      bindkey -v

      # Load local/work-specific configs
      [ -f "$HOME/.secrets" ] && source "$HOME/.secrets"
    '';
  };

  # ============================================================================
  # Environment Variables (cross-shell)
  # ============================================================================
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PNPM_HOME = "${config.home.homeDirectory}/Library/pnpm";
  };

  # PATH additions (cross-shell)
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/.rustup/toolchains/stable-aarch64-apple-darwin/bin"
    "$PNPM_HOME"
  ] ++ lib.optionals isDarwin [
    # macOS-specific paths if needed
  ] ++ lib.optionals isLinux [
    # Linux-specific paths if needed
  ];
}
