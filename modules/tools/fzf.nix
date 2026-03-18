# Fuzzy finder.
# Contributes to flake.modules.homeManager.base.
{ ... }:
{
  flake.modules.homeManager.base =
    {
      pkgs,
      lib,
      ...
    }:
    {
      programs.fzf = {
        enable = true;
      };
    };
}
