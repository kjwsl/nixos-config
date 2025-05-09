{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ray.home.modules.shell;
in
{
  options.ray.home.modules.shell = {
    fish.enable = mkEnableOption "fish shell";
    zoxide.enable = mkEnableOption "zoxide - a smarter cd command";
    bat.enable = mkEnableOption "bat - a cat clone with syntax highlighting";
    eza.enable = mkEnableOption "eza - a modern replacement for ls";
  };

  config = mkIf (cfg.fish.enable || cfg.zoxide.enable || cfg.bat.enable || cfg.eza.enable) {
    imports = [
      ./fish.nix
      ./zoxide.nix
      ./bat.nix
      ./eza.nix
    ];
  };
}
