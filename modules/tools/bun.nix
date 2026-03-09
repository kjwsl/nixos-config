# Bun JavaScript runtime.
# Contributes to flake.modules.homeManager.base.
{...}: {
  flake.modules.homeManager.base = {...}: {
    programs.bun = {
      enable = true;
      enableGitIntegration = true;
    };
  };
}
