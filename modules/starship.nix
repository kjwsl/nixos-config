{ config, pkgs, ... }:

{
  # Starship - Cross-shell prompt
  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      # Fast startup - scan timeout
      scan_timeout = 10;

      # Format string for the prompt
      format = "$all";

      # Character settings
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };

      # Directory settings
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        fish_style_pwd_dir_length = 1;
      };

      # Git settings
      git_branch = {
        symbol = " ";
        format = "[$symbol$branch]($style) ";
      };

      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        conflicted = "🏳";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        untracked = "?";
        stashed = "$";
        modified = "!";
        staged = "+";
        renamed = "»";
        deleted = "✘";
      };

      # Language/tool indicators
      nix_shell = {
        symbol = " ";
        format = "[$symbol$state( \\($name\\))]($style) ";
      };

      rust = {
        symbol = " ";
      };

      python = {
        symbol = " ";
      };

      nodejs = {
        symbol = " ";
      };
    };
  };
}
