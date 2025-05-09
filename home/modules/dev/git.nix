{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.dev.git;
in
{
  options.ray.home.modules.dev.git = {
    enable = mkEnableOption "Git version control";
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      userEmail = "ray@example.com";
      userName = "ray";
      aliases = {
        i = "init";
        aa = "add .";
        co = "commit";
        ca = "commit -a";
        cm = "commit -am";
        ps = "push";
        pu = "pull";
        stu = "status HEAD";
        sts = "stash";
        sw = "switch";
        di = "diff";
      };
    };
    
    home.packages = with pkgs; [
      git
      git-lfs
      lazygit
    ];
  };
} 