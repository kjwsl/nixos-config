{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.apps.qbittorrent;
  # Only define Linux packages if we're on Linux
  qbittorrentPackages = if pkgs.stdenv.isLinux then with pkgs; [
    qbittorrent
  ] else [];
in
{
  options.ray.home.modules.apps.qbittorrent = {
    enable = mkEnableOption "qBittorrent torrent client";
  };

  config = mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    home.packages = qbittorrentPackages;
  };
} 