# Intelli-Shell
# Contributes to flake.modules.homeManager.base.
{...}: {
  flake.modules.homeManager.base = {...}: {
    programs.intelli-shell = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };
  };
}
