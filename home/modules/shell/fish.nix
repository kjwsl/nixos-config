{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.shell.fish;
in
{
  options.ray.home.modules.shell.fish = {
    enable = mkEnableOption "Fish shell" // { default = false; };
  };

  config = mkMerge [
    (mkIf false {}) # Always disabled, no config
    (mkIf cfg.enable {
      home.packages = with pkgs; [
        fish
        oh-my-fish
      ];
      
      home.shellAliases = {
        g = "git";
      };
      
      xdg.configFile = {
        "fish/config.fish" = {
          text = ''
            if test -d $HOME/.local/share/omf
              source $HOME/.local/share/omf/init.fish
            end
            
            function fish_greeting
            end
            
            alias ls="ls -ah --color"
            alias ll="ls -lah --color"
            
            fish_add_path $HOME/.local/bin
            
            if type -q zoxide
              zoxide init fish | source
            end
            
            fish_vi_key_bindings
          '';
        };
        
        "fish/conf.d/omf-install.fish" = {
          text = ''
            if not test -d $HOME/.local/share/omf
              curl -L https://get.oh-my-fish > /tmp/omf-install
              fish /tmp/omf-install --noninteractive
              rm /tmp/omf-install
            end
          '';
        };
      };
    })
  ];
} 