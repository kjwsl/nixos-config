# Direnv environment loader.
# Contributes to flake.modules.homeManager.base.
{...}: {
  flake.modules.homeManager.base = {...}: {
    programs.direnv = {
      nix-direnv = {
        enable = true;
      };
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      mise.enable = true;
    };
  };
}
