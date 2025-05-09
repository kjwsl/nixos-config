{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ray.home.modules.apps.steam;
in
{
  options.ray.home.modules.apps.steam = {
    enable = mkEnableOption "Steam gaming platform";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      steam
      steam-run
    ];

    # Steam configuration
    home.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    };

    # Create Steam compatibility tools directory
    home.activation = {
      createSteamCompatDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p $VERBOSE_ARG "$HOME/.steam/root/compatibilitytools.d"
      '';
    };
  };
} 