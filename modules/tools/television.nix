# Television fuzzy finder + nix-search-tv integration.
# Contributes to flake.modules.homeManager.base.
{...}: {
  flake.modules.homeManager.base = {...}: {
    programs.television = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };

    programs.nix-search-tv.enableTelevisionIntegration = true;
  };
}
