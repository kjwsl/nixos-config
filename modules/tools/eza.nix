# Eza, a modern replacement for ls.
# Contributes to flake.modules.homeManager.base.
{...}: {
  flake.modules.homeManager.base = {...}: {
    programs.eza = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = false;
      icons = "auto";
      colors = "auto";
      git = true;
    };
  };
}
