{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ray.home.modules.apps.steam;
  # Only define Linux packages if we're on Linux
  steamPackages = if pkgs.stdenv.isLinux then with pkgs; [
    steam
    steam-run
  ] else [];
in
{
  options.ray.home.modules.apps.steam = {
    enable = mkEnableOption "Steam gaming platform";
  };

  config = mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    # Define home packages for Steam
    home.packages = steamPackages;

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