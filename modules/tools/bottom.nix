# Bottom system monitor.
# Contributes to flake.modules.homeManager.base.
{...}: {
  flake.modules.homeManager.base = {...}: {
    programs.bottom.enable = true;
  };
}
