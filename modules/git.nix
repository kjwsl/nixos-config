{ config, pkgs, ... }:

{
  # Git configuration
  programs.git = {
    enable = true;

    # Delta - Enhanced diff viewer
    delta = {
      enable = true;
      options = {
        # Appearance
        side-by-side = true;
        line-numbers = true;

        # Syntax theme
        syntax-theme = "Dracula";

        # Layout
        navigate = true;

        # Features
        features = "decorations";

        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-style = "bold yellow ul";
          file-decoration-style = "none";
        };
      };
    };

    # Git aliases
    aliases = {
      # Short commands
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";

      # Log variants
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
      lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";

      # Useful shortcuts
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "log --graph --all --decorate --oneline";
      amend = "commit --amend --no-edit";
    };

    # Git configuration
    extraConfig = {
      # Core settings
      core = {
        editor = "nvim";
        autocrlf = "input";
      };

      # UI colors
      color = {
        ui = "auto";
      };

      # Pull behavior
      pull = {
        rebase = false;
      };

      # Push behavior
      push = {
        default = "simple";
        autoSetupRemote = true;
      };

      # Init settings
      init = {
        defaultBranch = "main";
      };

      # Merge settings
      merge = {
        conflictStyle = "diff3";
      };

      # Diff settings
      diff = {
        colorMoved = "default";
      };

      # Rebase settings
      rebase = {
        autoStash = true;
      };
    };
  };

  # Lazygit - Terminal UI for git commands
  programs.lazygit = {
    enable = true;
  };
}
