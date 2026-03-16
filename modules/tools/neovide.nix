# Zoxide smart directory jumper.
# Contributes to flake.modules.homeManager.base.
{ ... }:
{
  flake.modules.homeManager.base =
    { pkgs, lib, ... }:
    {
      programs.neovide = {
        enable = false;
        settings = {
          neovim-bin = "${lib.getExe pkgs.neovim}";
        };
      };
    };
}
