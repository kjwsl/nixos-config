# Nushell configuration.
# Contributes to flake.modules.homeManager.base.
{
  ...
}:
{
  flake.modules.homeManager.base =
    {
      pkgs,
      config,
      ...
    }:
    {
      programs.nushell = {
        enable = true;
        configFile.source = ./config.nu;
        extraEnv = ''
          # Directly export secret values if the decrypted file exists
          let ctx7_path = ("${config.sops.secrets."context7-api-key".path}" | path expand)
          if ($ctx7_path | path exists) {
            $env.CONTEXT7_API_KEY = (open $ctx7_path | str trim)
          }
        '';
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
          # highlight
          gstat
          query
        ];
      };
    };
}
