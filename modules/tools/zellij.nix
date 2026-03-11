# Zellij Terminal Multiplexer
# Contributes to flake.modules.homeManager.base.
{ ... }: {
  flake.modules.homeManager.base = { pkgs, ... }: {
    xdg.configFile."zellij/plugins/room.wasm".source = pkgs.fetchurl {
      url = "https://github.com/rvcas/room/releases/download/v1.2.1/room.wasm";
      hash = "sha256-kLSDpAt2JGj7dYYhYFh6BfvtzVwTrcs+0jHwG/nActE=";
    };
    programs.zellij = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      settings = {
        web_server = true;

        show_startup_tips = false;
        keybinds = {
          "shared_except \"locked\"" = {
            "bind \"Ctrl y\"" = {
              "LaunchOrFocusPlugin \"file:~/.config/zellij/plugins/room.wasm\"" = {
                floating = true;
                ignore_case = true;
                quick_jump = true;
              };
            };
          };
        };
      };
    };
  };
}
