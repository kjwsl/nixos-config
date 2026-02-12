{ config, pkgs, ... }:

{
  # Fish shell configuration
  programs.fish = {
    enable = true;
    
    shellAliases = {
      # Editor shortcuts
      v = "nvim";
      vim = "nvim";
    };
    
    interactiveShellInit = ''
      # Disable fish greeting
      set fish_greeting
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
