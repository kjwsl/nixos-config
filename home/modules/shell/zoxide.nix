{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.shell.zoxide;
in
{
  options.ray.home.modules.shell.zoxide = {
    enable = mkEnableOption "zoxide directory navigation";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      zoxide
    ];
    
    home.sessionVariables = {
      _ZO_DATA_DIR = "$HOME/.local/share/zoxide";
    };
    
    xdg.configFile = {
      "bash/bash_profile.d/zoxide.sh" = {
        text = ''
          if command -v zoxide >/dev/null; then
            eval "$(zoxide init bash)"
          fi
        '';
      };
      
      "zsh/zshrc.d/zoxide.zsh" = {
        text = ''
          if (( $+commands[zoxide] )); then
            eval "$(zoxide init zsh)"
          fi
        '';
      };
      
      "fish/conf.d/zoxide.fish" = {
        text = ''
          if type -q zoxide
            zoxide init fish | source
          fi
        '';
      };
    };
    
    home.shellAliases = {
      cd = "z";
      cdi = "zi";
    };
  };
} 