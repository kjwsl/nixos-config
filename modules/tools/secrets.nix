# Secret management using sops-nix and Bitwarden.
# Contributes to flake.modules.homeManager.base.
{
  config,
  pkgs,
  lib,
  ...
}: {
  flake.modules.homeManager.base = {
    config,
    pkgs,
    ...
  }: {
    # Import sops-nix is already done in modules/home.nix for all home-manager configs

    sops = {
      defaultSopsFile = ../../secrets/secrets.yaml;
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    };

    # Define secrets here as we sync them
    sops.secrets."context7-api-key" = {};
  };
}
