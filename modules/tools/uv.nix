# uv Python package manager.
# Contributes to flake.modules.homeManager.base.
{...}: {
  flake.modules.homeManager.base = {...}: {
    programs.uv = {
      enable = true;
      settings.python-preference = "managed";
    };
  };
}
