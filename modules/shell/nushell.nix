# Nushell configuration.
# Contributes to flake.modules.homeManager.base.
{...}: {
  flake.modules.homeManager.base = {pkgs, ...}: {
    programs.nushell = {
      enable = true;
      settings = {
        show_banner = false;
        completions.external = {
          enable = true;
          max_results = 200;
        };
      };
      plugins = with pkgs.nushellPlugins; [
        formats
        skim
        semver
        highlight
        gstat
        query
      ];
    };
  };
}
