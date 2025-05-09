{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.dev.rust;
in
{
  options.ray.home.modules.dev.rust = {
    enable = mkEnableOption "Rust development tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      rustup
      rust-analyzer
      cargo
      rustc
    ];
  };
} 