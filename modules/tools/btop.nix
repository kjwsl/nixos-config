# Zoxide smart directory jumper.
# Contributes to flake.modules.homeManager.base.
{...}: {
  flake.modules.homeManager.base = {...}: {
    programs.btop = {
      enable = true;
      settings = {
          vim_keys = true;
          rounded_corners = true;
          proc_sorting = "cpu lazy";
      };
    };
  };
}
