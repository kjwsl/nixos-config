# Secret management using sops-nix and Bitwarden.
# Contributes to flake.modules.homeManager.base.
{
  inputs,
  ...
}: {
  flake.modules.homeManager.base = {
    config,
    ...
  }: {
    _file = ./secrets.nix;
    imports = [inputs.sops-nix.homeManagerModules.sops];

    sops = {
      defaultSopsFile = ../../secrets/secrets.yaml;
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    };

    # Define secrets here as we sync them
    sops.secrets."context7-api-key" = {};
  };
}
