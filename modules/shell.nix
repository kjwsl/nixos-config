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
      
      # Enhanced eza aliases (with git and icons)
      ls = "eza --icons --group-directories-first -a --git";
      ll = "eza --icons --group-directories-first -la --git --header";
      la = "eza --icons --group-directories-first -la --git --header --extended";
      lt = "eza --icons --tree --git --level=3";
      
      # Quick navigation
      zo = "z (dirname (fzf))";
      
      # System monitoring shortcuts  
      top = "btop";
      htop = "btop";
      du = "dust";
      df = "duf";
      ps = "procs";
      find = "fd";
      grep = "rg";
      cat = "bat";
      
      # Git shortcuts
      gst = "git status";
      gco = "git checkout";
      gcb = "git checkout -b";
      gp = "git push";
      gl = "git pull";
      ga = "git add";
      gc = "git commit";
      gd = "git diff";
      glg = "git log --oneline --graph";
    };
    
    shellInit = ''
      # Disable greeting message
      set -g fish_greeting

      # Core settings
      export EDITOR="nvim"
      export VISUAL=$EDITOR
      export PAGER="less -FR"
      export MANPAGER="sh -c 'col -bx | bat -l man -p'"
      
      # Enable transient prompt
      set -g fish_transient_prompt 1

      # Performance optimizations
      set -g fish_vi_force_cursor 1
      set -g fish_cursor_default block
      set -g fish_cursor_insert line
      set -g fish_cursor_replace_one underscore
      set -g fish_cursor_visual block

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
      
      # Development environment
      export RUST_LOG="warn"
      export CARGO_TERM_COLOR="always"
      export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"
    '';
    
    interactiveShellInit = ''
      # Development tools initialization
      if type -q mise
          mise activate fish | source
      end
      
      # Theme - Explicitly use dark mode variant
      fish_config theme choose "Catppuccin Mocha" --color-theme=dark

      # Load Functions
      if test -f $__fish_config_dir/functions.fish
          source $__fish_config_dir/functions.fish
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

      # Enhanced key bindings
      bind -M insert \cf accept-autosuggestion
      bind -M insert \ce end-of-line
      bind -M insert \ca beginning-of-line
      bind -M insert \ck kill-line

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
      
      # Enhanced file operations with confirmation
      rmi = ''
        if test (count $argv) -eq 0
            echo "Usage: rmi <files...>"
            return 1
        end
        
        echo "Files to remove:"
        for file in $argv
            echo "  - $file"
        end
        
        read -l -P "Continue? [y/N] " confirm
        if test "$confirm" = "y" -o "$confirm" = "Y"
            rm -i $argv
        end
      '';
      
      # Quick project navigation
      projects = ''
        set project_dir (find ~/repos ~/projects ~/work -maxdepth 2 -type d 2>/dev/null | fzf --preview 'eza --tree --level=2 {}')
        if test -n "$project_dir"
            cd $project_dir
        end
      '';
      
      # Git worktree helper
      gwt = ''
        set branch_name $argv[1]
        if test -z "$branch_name"
            echo "Usage: gwt <branch-name>"
            return 1
        end
        
        git worktree add ../(basename $PWD)-$branch_name $branch_name
        cd ../(basename $PWD)-$branch_name
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
      # --- nixpkgs fishPlugins ---
      { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
      { name = "done"; src = pkgs.fishPlugins.done.src; }
      { name = "sponge"; src = pkgs.fishPlugins.sponge.src; }
      { name = "puffer"; src = pkgs.fishPlugins.puffer.src; }
      { name = "bass"; src = pkgs.fishPlugins.bass.src; }
      { name = "spark"; src = pkgs.fishPlugins.spark.src; }
      { name = "plugin-git"; src = pkgs.fishPlugins.plugin-git.src; }

      # --- fetchFromGitHub (not in nixpkgs) ---
      {
        name = "nix-env.fish";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
          hash = "sha256-RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
        };
      }
      {
        name = "replay.fish";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "replay.fish";
          rev = "d2ecacd3fe7126e822ce8918389f3ad93b14c86c";
          hash = "sha256-TzQ97h9tBRUg+A7DSKeTBWLQuThicbu19DHMwkmUXdg=";
        };
      }
      {
        name = "catppuccin";
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "fish";
          rev = "521560ce2075ca757473816aa31914215332bac9";
          hash = "sha256-5CXdzym6Vp+FbKTVBtVdWoh3dODudADIzOLXIyIIxgQ=";
        };
      }
      {
        name = "abbreviation-tips";
        src = pkgs.fetchFromGitHub {
          owner = "gazorby";
          repo = "fish-abbreviation-tips";
          rev = "8ed76a62bb044ba4ad8e3e6832640178880df485";
          hash = "sha256-F1t81VliD+v6WEWqj1c1ehFBXzqLyumx5vV46s/FZRU=";
        };
      }
    ];
  };
  
  # ===== ADVANCED CLI TOOL CONFIGURATIONS =====
  
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      # Disable sync for privacy
      sync_address = "";
      sync = {
        records = false;
      };
      
      # Search configuration
      search_mode = "prefix";
      search_mode_shell_up_key_binding = "prefix";
      filter_mode_shell_up_key_binding = "session";
      
      # UI configuration  
      style = "compact";
      inline_height = 20;
      show_preview = true;
      max_preview_height = 4;
      show_help = true;
      exit_mode = "return-original";
      
      # Privacy and filtering
      secrets_filter = true;
      history_filter = [
        "^password"
        "^passwd"
        "^token"
        "^key"
        "^secret"
        "^api"
        "^auth"
        "AWS_"
        "GITHUB_TOKEN"
        "OPENAI_API_KEY"
      ];
      
      # Performance
      update_check = false;
      
      # Advanced features
      enter_accept = false;
      keymap_mode = "vim-normal";
      workspaces = true;
      common_prefix = ["sudo" "doas"];
      common_subcommands = [
        "git:checkout,commit,push,pull,rebase,merge,log,status,diff,add,reset,stash"
        "docker:run,build,pull,push,stop,rm,ps,images,logs,exec"
        "kubectl:get,apply,delete,describe,logs,exec,port-forward"
      ];
    };
  };
  
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true; 
    enableZshIntegration = true;
    options = [ 
      "--cmd z"
    ];
  };
  
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    
    # Catppuccin Mocha colors
    colors = {
      "bg+" = "#313244";
      "bg" = "#1e1e2e";
      "spinner" = "#f5e0dc";
      "hl" = "#f38ba8";
      "fg" = "#cdd6f4";
      "header" = "#f38ba8";
      "info" = "#cba6f7";
      "pointer" = "#f5e0dc";
      "marker" = "#f5e0dc";
      "fg+" = "#cdd6f4";
      "prompt" = "#cba6f7";
      "hl+" = "#f38ba8";
    };
    
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--margin=1,2"
      "--padding=1"
      "--info=inline"
      "--prompt='❯ '"
      "--pointer='❯'"
      "--marker='❯'"
      "--ansi"
    ];
    
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetOptions = [
      "--preview 'bat --color=always --style=header,grid --line-range :300 {}'"
      "--preview-window=right:60%:wrap"
    ];
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
    changeDirWidgetOptions = [
      "--preview 'eza --tree --color=always {} | head -200'"
      "--preview-window=right:60%:wrap"
    ];
    historyWidgetOptions = [
      "--preview 'echo {}'"
      "--preview-window down:3:hidden:wrap"
      "--bind 'ctrl-/:toggle-preview'"
    ];
  };
  
  programs.bat = {
    enable = true;
    config = {
      theme = "Catppuccin-mocha";
      style = "numbers,changes,header-filename,header-filesize,grid";
      map-syntax = [
        ".ignore:Git Ignore"
        ".gitignore:Git Ignore"
        ".env:Bash"
        "Justfile:Just"
        "justfile:Just"
      ];
    };
    themes = {
      catppuccin-mocha = {
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "bat";
          rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
          sha256 = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
        };
        file = "Catppuccin-mocha.tmTheme";
      };
    };
  };
  
  programs.eza = {
    enable = true;
    # enableAliases is deprecated - using shell-specific integrations instead
    git = true;
    icons = "auto";
    extraOptions = [
      "--group-directories-first"
      "--header"
      "--classify"
    ];
  };
  
  programs.bottom = {
    enable = true;
    settings = {
      flags = {
        avg_cpu = false;
        battery = true;
        color = "auto";
        current_usage = true;
        group_processes = false;
        hide_avg_cpu = false;
        hide_table_gap = false;
        left_legend = false;
        mem_as_value = false;
        network_use_binary_prefix = false;
        network_use_bytes = false;
        network_use_log = false;
        process_command = false;
        regex = false;
        show_table_scroll_position = false;
        temperature_type = "c";
        time_delta = 60000;
        tree = false;
        use_old_network_legend = false;
        whole_word = false;
      };
      colors = {
        # Catppuccin Mocha theme
        table_header_color = "#cdd6f4";
        all_entry_color = "#cdd6f4";
        entry_color = "#cdd6f4";
        graph_color = "#89b4fa";
        border_color = "#45475a";
        highlighted_border_color = "#89b4fa";
        text_color = "#cdd6f4";
        avg_entry_color = "#fab387";
        cpu_core_colors = [
          "#f38ba8"
          "#fab387"  
          "#f9e2af"
          "#a6e3a1"
          "#94e2d5"
          "#89b4fa"
          "#cba6f7"
          "#f5c2e7"
        ];
        ram_color = "#a6e3a1";
        swap_color = "#fab387";
        rx_color = "#a6e3a1";
        tx_color = "#f38ba8";
        rx_total_color = "#94e2d5";
        tx_total_color = "#cba6f7";
        cpu_color = "#89b4fa";
        memory_color = "#a6e3a1";
        network_color = "#f9e2af";
        process_color = "#cdd6f4";
      };
    };
  };
  
  programs.broot = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      modal = true;
      skin = {
        default = "gray(20) none / gray(15) none";
        tree = "ansi(94) None / gray(3) None";
        parent = "gray(18) None / gray(13) None";
        file = "gray(20) None / gray(15) None";
        directory = "ansi(208) None Bold / ansi(172) None bold";
        exe = "Cyan None";
        link = "Magenta None";
        pruning = "gray(12) None Italic";
        perm__ = "gray(5) None";
        perm_r = "ansi(94) None";
        perm_w = "ansi(132) None";
        perm_x = "ansi(65) None";
        owner = "ansi(138) None";
        group = "ansi(131) None";
        count = "ansi(136) gray(3)";
        dates = "ansi(66) None";
        sparse = "ansi(214) None";
        content_extract = "ansi(29) None";
        content_match = "ansi(34) None";
        git_branch = "ansi(229) None";
        git_insertions = "ansi(28) None";
        git_deletions = "ansi(160) None";
        git_status_current = "gray(5) None";
        git_status_modified = "ansi(28) None";
        git_status_new = "ansi(94) None Bold";
        git_status_ignored = "gray(17) None";
        git_status_conflicted = "ansi(88) None";
        git_status_other = "ansi(88) None";
        selected_line = "None gray(5) / None gray(4)";
        char_match = "Yellow None";
        file_error = "Red None";
        flag_label = "gray(15) None";
        flag_value = "ansi(208) None Bold";
        input = "White None / gray(15) gray(2)";
        status_error = "gray(22) ansi(124)";
        status_job = "ansi(220) gray(5)";
        status_normal = "gray(20) gray(3) / gray(2) gray(2)";
        status_italic = "ansi(208) gray(3) / gray(2) gray(2)";
        status_bold = "ansi(208) gray(3) Bold / gray(2) gray(2)";
        status_code = "ansi(229) gray(3) / gray(2) gray(2)";
        status_ellipsis = "gray(19) gray(1) / gray(2) gray(2)";
        purpose_normal = "gray(20) gray(2)";
        purpose_italic = "ansi(178) gray(2)";
        purpose_bold = "ansi(178) gray(2) Bold";
        purpose_ellipsis = "gray(20) gray(2)";
        scrollbar_track = "gray(7) None / gray(4) None";
        scrollbar_thumb = "gray(22) None / gray(14) None";
        help_paragraph = "gray(20) None";
        help_bold = "ansi(208) None Bold";
        help_italic = "ansi(166) None";
        help_code = "gray(21) gray(3)";
        help_headers = "ansi(208) None";
        help_table_border = "ansi(239) None";
        preview = "gray(20) gray(1) / gray(18) gray(2)";
        preview_title = "gray(23) gray(1) / gray(21) gray(2)";
        preview_separation = "gray(17) None / gray(14) None";
        preview_match = "None ansi(29)";
        hex_null = "gray(11) None";
        hex_ascii_graphic = "gray(18) None";
        hex_ascii_whitespace = "ansi(143) None";
        hex_ascii_other = "ansi(215) None";
        hex_non_ascii = "ansi(167) None";
      };
    };
  };
  
  programs.nushell = {
    enable = true;
    
    extraConfig = ''
      # Nushell power-user configuration
      $env.config = {
        show_banner: false
        buffer_editor: "nvim"
        edit_mode: "vi"
        cursor_shape: {
          vi_insert: line
          vi_normal: block
        }
        use_grid_icons: true
        footer_mode: "25"
        float_precision: 2
        history: {
          max_size: 100000
          sync_on_enter: true
          file_format: "plaintext"
          isolation: false
        }
        completions: {
          case_sensitive: false
          quick: true
          partial: true
          algorithm: "fuzzy"
          external: {
            enable: true
            max_results: 100
            completer: null
          }
        }
        filesize: {
          metric: false
          format: "auto"
        }
        color_config: {
          separator: white
          leading_trailing_space_bg: { attr: n }
          header: green_bold
          empty: blue
          bool: light_cyan
          int: white
          filesize: cyan
          duration: white
          date: purple
          range: white
          float: white
          string: white
          nothing: white
          binary: white
          cellpath: white
          row_index: green_bold
          record: white
          list: white
          block: white
          hints: dark_gray
          search_result: red
          shape_and: purple_bold
          shape_binary: purple_bold
          shape_block: blue_bold
          shape_bool: light_cyan
          shape_closure: green_bold
          shape_custom: green
          shape_datetime: cyan_bold
          shape_directory: cyan
          shape_external: cyan
          shape_externalarg: green_bold
          shape_filepath: cyan
          shape_flag: blue_bold
          shape_float: purple_bold
          shape_garbage: { fg: white bg: red attr: b }
          shape_globpattern: cyan_bold
          shape_int: purple_bold
          shape_internalcall: cyan_bold
          shape_list: cyan_bold
          shape_literal: blue
          shape_match_pattern: green
          shape_matching_brackets: { attr: u }
          shape_nothing: light_cyan
          shape_operator: yellow
          shape_or: purple_bold
          shape_pipe: purple_bold
          shape_range: yellow_bold
          shape_record: cyan_bold
          shape_redirection: purple_bold
          shape_signature: green_bold
          shape_string: green
          shape_string_interpolation: cyan_bold
          shape_table: blue_bold
          shape_variable: purple
          shape_vardecl: purple
        }
        menus: [
          {
            name: completion_menu
            only_buffer_difference: false
            marker: "| "
            type: {
              layout: columnar
              columns: 4
              col_width: 20
              col_padding: 2
            }
            style: {
              text: green
              selected_text: green_reverse
              description_text: yellow
            }
          }
          {
            name: history_menu
            only_buffer_difference: true
            marker: "? "
            type: {
              layout: list
              page_size: 10
            }
            style: {
              text: green
              selected_text: green_reverse
              description_text: yellow
            }
          }
          {
            name: help_menu
            only_buffer_difference: true
            marker: "? "
            type: {
              layout: description
              columns: 4
              col_width: 20
              col_padding: 2
              selection_rows: 4
              description_rows: 10
            }
            style: {
              text: green
              selected_text: green_reverse
              description_text: yellow
            }
          }
        ]
        keybindings: [
          {
            name: completion_menu
            modifier: none
            keycode: tab
            mode: [emacs vi_normal vi_insert]
            event: {
              until: [
                { send: menu name: completion_menu }
                { send: menunext }
                { edit: complete }
              ]
            }
          }
          {
            name: history_menu
            modifier: control
            keycode: char_r
            mode: [emacs vi_normal vi_insert]
            event: { send: menu name: history_menu }
          }
          {
            name: help_menu
            modifier: none
            keycode: f1
            mode: [emacs vi_normal vi_insert]
            event: { send: menu name: help_menu }
          }
        ]
      }
    '';
    
    shellAliases = {
      v = "nvim";
      g = "git";
      ls = "eza --icons --group-directories-first -a --git";
      ll = "eza --icons --group-directories-first -la --git --header";
      la = "eza --icons --group-directories-first -la --git --header --extended";
      tree = "eza --tree --git --level=3";
      cat = "bat";
      top = "btop";
      htop = "btop";
      du = "dust";
      df = "duf";
      ps = "procs";
      find = "fd";
      grep = "rg";
    };
    
    environmentVariables = {
      EDITOR = "nvim";
      PAGER = "less -FR";
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    };
  };
  
  # Additional fish config files that need to be managed as raw files
  home.file = {
    ".config/fish/alias.fish".source = ../dotfiles/alias.fish;
    ".config/fish/functions.fish".source = ../dotfiles/functions.fish;
    # fish_plugins no longer needed — plugins managed by programs.fish.plugins
    
    # Ripgrep config for better searching
    ".config/ripgrep/ripgreprc".text = ''
      # Follow symbolic links
      --follow
      
      # Search in hidden files/directories
      --hidden
      
      # Use glob patterns  
      --glob=!.git/*
      --glob=!node_modules/*
      --glob=!.DS_Store
      --glob=!*.tmp
      --glob=!*.temp
      
      # Case insensitive by default
      --smart-case
      
      # Show line numbers
      --line-number
      
      # Show column numbers
      --column
      
      # Trim whitespace
      --trim
      
      # Colors (Catppuccin Mocha)
      --colors=line:fg:249,226,175
      --colors=line:style:bold
      --colors=path:fg:137,180,250
      --colors=path:style:bold
      --colors=match:fg:243,139,168
      --colors=match:style:bold
      --colors=match:bg:49,50,68
    '';
  };
}