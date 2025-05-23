{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.apps.qbittorrent;
in
{
  options.ray.home.modules.apps.qbittorrent = {
    enable = mkEnableOption "qBittorrent torrent client";
  };

  config = mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    home.packages = with pkgs; [
      qbittorrent
    ];
  };
} 