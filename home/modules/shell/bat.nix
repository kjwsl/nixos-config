{ config, lib, pkgs, ... }:

with lib;
let cfg = config.larp.shell.bat;
in
{
  options.larp.shell.bat = {
    enable = mkEnableOption "bat configuration";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.bat ];
  };
}

