# Zoxide smart directory jumper.
# Contributes to flake.modules.homeManager.base.
{ ... }:
{
  flake.modules.homeManager.base =
    { pkgs, lib, ... }:
    {
      programs.neovide = {
        enable = true;
        settings = {
          neovim-bin = "${lib.getExe pkgs.neovim}";
        };
      };
    };
}
