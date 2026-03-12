# Zellij Terminal Multiplexer
# Contributes to flake.modules.homeManager.base.
{
  ...
}:
{
  flake.modules.homeManager.base =
    {
      pkgs,
      ...
    }:
    let
      zellijPlugins = {
        room = pkgs.fetchurl {
          url = "https://github.com/rvcas/room/releases/download/v1.2.1/room.wasm";
          hash = "sha256-kLSDpAt2JGj7dYYhYFh6BfvtzVwTrcs+0jHwG/nActE=";
        };
        vimZellijNavigator = pkgs.fetchurl {
          url = "https://github.com/hiasr/vim-zellij-navigator/releases/download/0.3.0/vim-zellij-navigator.wasm";
          hash = "sha256-d+Wi9i98GmmMryV0ST1ddVh+D9h3z7o0xIyvcxwkxY0=";
        };
      };
    in
    {
      programs.zellij = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        enableFishIntegration = true;
        settings = {
          web_server = true;

          show_startup_tips = false;
        };
        extraConfig = ''
          keybinds {
              shared_except "locked" {
                  bind "Ctrl y" = {
                      LaunchOrFocusPlugin "${zellijPlugins.room}" = {
                          floating true;
                          ignore_case true;
                          quick_jump true;
                      };
                  };
                  bind "Ctrl h" {
                      MessagePlugin ${zellijPlugins.vimZellijNavigator} {
                          name "move_focus_or_tab";
                          payload "left";

                          // Plugin Configuration
                          move_mod "ctrl"; // Optional, should be added on every move command if changed.
                          use_arrow_keys "false"; // Optional, uses arrow keys instead of hjkl. Should be added to every command where you want to use it.
                      };
                  }

                  bind "Ctrl j" {
                      MessagePlugin ${zellijPlugins.vimZellijNavigator} {
                          name "move_focus";
                          payload "down";

                          move_mod "ctrl";
                          use_arrow_keys "false";
                      };
                  }

                  bind "Ctrl k" {
                      MessagePlugin ${zellijPlugins.vimZellijNavigator} {
                          name "move_focus";
                          payload "up";

                          move_mod "ctrl";
                          use_arrow_keys "false";
                      };
                  }

                  bind "Ctrl l" {
                      MessagePlugin ${zellijPlugins.vimZellijNavigator} {
                          name "move_focus_or_tab";
                          payload "right";

                          move_mod "ctrl"; // Optional, should be added on every command if you want to use it
                          use_arrow_keys "false";
                      };
                  }

                  bind "Alt h" {
                      MessagePlugin ${zellijPlugins.vimZellijNavigator} {
                          name "resize";
                          payload "left";

                          resize_mod "alt";
                      };
                  }

                  bind "Alt j" {
                      MessagePlugin ${zellijPlugins.vimZellijNavigator} {
                          name "resize";
                          payload "down";

                          resize_mod "alt";
                      };
                  }

                  bind "Alt k" {
                      MessagePlugin ${zellijPlugins.vimZellijNavigator} {
                          name "resize";
                          payload "up";

                          resize_mod "alt";
                      };
                  }

                  bind "Alt l" {
                      MessagePlugin ${zellijPlugins.vimZellijNavigator} {
                          name "resize";
                          payload "right";

                          resize_mod "alt";
                      };
                  }
              }
          }
        '';
      };
    };
}
