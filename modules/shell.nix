{ config, pkgs, lib, ... }:

{
  programs.fish = {
    enable = true;
    
    shellAliases = {
      # Navigation and listing
      tree = "tree -C";
      v = "nvim";
      "v." = "nvim .";
      g = "git";
      
      # Performance
      fish-bench = "time fish -i -c exit";
      fish_reload = "source $__fish_config_dir/config.fish";
      
      # Eza aliases (conditional on eza being available)
      ls = "eza --icons --group-directories-first -a";
      ll = "eza --icons --group-directories-first -la";
      
      # Zoxide + fzf convenience
      zo = "z (dirname (fzf))";
    };
    
    shellInit = ''
      # Disable greeting message
      set -g fish_greeting

      # Core settings
      export EDITOR="nvim"
      export VISUAL=$EDITOR
      
      # Enable transient prompt
      set -g fish_transient_prompt 1

      # Paths
      export PATH="$HOME/.local/bin:$PATH"
      fish_add_path "$HOME/.rustup/toolchains/stable-aarch64-apple-darwin/bin/"
      fish_add_path "$HOME/.cargo/bin/"
      export PKG_CONFIG_PATH="$HOME/.luarocks/share/lua/5.1:$HOME/.nix-profile/bin:$HOME/.local/lib/pkgconfig:$PKG_CONFIG_PATH"
      
      # pnpm
      set -gx PNPM_HOME "/Users/ray/Library/pnpm"
      if not string match -q -- $PNPM_HOME $PATH
        set -gx PATH "$PNPM_HOME" $PATH
      end
    '';
    
    interactiveShellInit = ''
      # Plugin Manager (Fisher) - Automatic Installation
      if not type -q fisher
          curl -sL https://git.io/fisher | source && fisher update
      end

      # Mise 
      if type -q mise
          mise activate fish | source
      end

      # Theme - Explicitly use dark mode variant
      fish_config theme choose "Catppuccin Mocha" --color-theme=dark

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

      # Initialize vi key bindings
      fish_vi_key_bindings

      # Secrets and Work
      if test -f $HOME/.secrets
          bass source $HOME/.secrets
      end

      if test -f $HOME/work.fish
          source $HOME/work.fish
      end

      # ntfy.sh notifications
      set -gx NTFY_TOPIC notify-3152210757
      
      # Neural Orchestrator Context Integration
      if test -d $HOME/.context/integrations/fish
          set -p fish_function_path $HOME/.context/integrations/fish
          if test -f $HOME/.context/integrations/fish/gemini-profiles.fish
              source $HOME/.context/integrations/fish/gemini-profiles.fish
          end
      end
    '';
    
    functions = {
      # Custom functions from functions.fish
      envsource = "for line in (cat $argv | grep -v '^#'); set item (string split -m 1 '=' $line); set -gx $item[1] $item[2]; end";
      
      pi = ''
        if type -q pacman
            sudo pacman -S --needed --noconfirm $argv
        end
      '';
      
      vf = "nvim (fzf -m --preview 'bat --style=numbers --color=always {}')";
      
      zf = ''
        set dir (find . -type d -print | fzf) || return
        z $dir
      '';
      
      notify = ''
        set -l msg (test (count $argv) -gt 0; and string join " " $argv; or echo "Task completed")
        set -l dir (string replace $HOME "~" $PWD)
        curl -s \
            -H "Title: 🔔 $hostname: Manual notification" \
            -d "$msg

Directory: $dir" \
            "ntfy.sh/$NTFY_TOPIC" >/dev/null 2>&1 &
      '';
      
      __notify_on_long_command = ''
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
    
    plugins = [
      # Core plugins that should be installed via Nix when available
      {
        name = "fzf";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
      {
        name = "sponge";
        src = pkgs.fishPlugins.sponge.src;
      }
      {
        name = "puffer";
        src = pkgs.fishPlugins.puffer.src;
      }
    ];
  };
  
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };
  
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
  
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };
  
  programs.eza = {
    enable = true;
  };
  
  programs.bat = {
    enable = true;
    config = {
      theme = "Catppuccin-mocha";
    };
  };
  
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
  };
  
  # Additional fish config files that need to be managed as raw files
  home.file = {
    ".config/fish/alias.fish".source = ~/.local/share/chezmoi/dot_config/fish/alias.fish;
    ".config/fish/functions.fish".source = ~/.local/share/chezmoi/dot_config/fish/functions.fish;
    ".config/fish/fish_plugins".source = ~/.local/share/chezmoi/dot_config/fish/fish_plugins;
  };
}