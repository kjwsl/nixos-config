{ config, pkgs, ... }:

{
  # Starship - Use existing starship.toml
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = pkgs.lib.importTOML ../starship.toml;
  };
}
