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
    
    home.shellAliases = {
      cd = "z";
      cdi = "zi";
    };
  };
} 