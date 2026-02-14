{ config, lib, pkgs, ... }:

with lib;

{
  options.programs.himalaya-custom = {
    enable = mkEnableOption "Himalaya email client";
  };

  config = mkIf config.programs.himalaya-custom.enable {
    # Install Himalaya
    home.packages = with pkgs; [
      himalaya
    ];

    # Himalaya uses TOML config at ~/.config/himalaya/config.toml
    # However, we'll let users configure it manually or via home-manager's
    # programs.himalaya module when it becomes available

    # Fish shell integration
    programs.fish.shellAliases = mkIf config.programs.fish.enable {
      # Email shortcuts
      him = "himalaya";
      himl = "himalaya list";
      himr = "himalaya read";
      hims = "himalaya search";
      himw = "himalaya write";
    };

    # Note: Himalaya stores data in:
    # - Config: ~/.config/himalaya/config.toml
    # - Cache: ~/Library/Caches/himalaya/ (macOS)
    # - Cache: ~/.cache/himalaya/ (Linux)
  };
}
