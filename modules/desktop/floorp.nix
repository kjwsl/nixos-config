# Nushell configuration.
# Contributes to flake.modules.homeManager.base.
{ pkgs
, config
, ...
}: {
  flake.modules.homeManager.base =
    { pkgs
    , config
    , ...
    }:
    {
      programs.floorp.enable = true;
    };
}
