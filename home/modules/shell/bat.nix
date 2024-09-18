{ config, lib, pkgs, ... }:

with lib;
let cfg = config.ray.modules.shell.bat;
in
{
  options.ray.modules.shell.bat = {
    enable = mkEnableOption "bat configuration";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.bat ];
  };
}

