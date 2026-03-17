# Zellij Terminal Multiplexer
# Contributes to flake.modules.homeManager.base.
{...}: {
  flake.modules.homeManager.base = {
    config,
    pkgs,
    lib,
    ...
  }: let
    zellijPlugins = {
      room = pkgs.fetchurl {
        url = "https://github.com/rvcas/room/releases/download/v1.2.1/room.wasm";
        hash = "sha256-kLSDpAt2JGj7dYYhYFh6BfvtzVwTrcs+0jHwG/nActE=";
      };
      vimZellijNavigator = pkgs.fetchurl {
        url = "https://github.com/hiasr/vim-zellij-navigator/releases/download/0.3.0/vim-zellij-navigator.wasm";
        hash = "sha256-d+Wi9i98GmmMryV0ST1ddVh+D9h3z7o0xIyvcxwkxY0=";
      };
      harpoon = pkgs.fetchurl {
        url = "https://github.com/Nacho114/harpoon/releases/download/v0.3.0/harpoon.wasm";
        hash = "sha256-f4z1enHx27vRFTN6MWOHgNfhjpuHbe8cgclwGIyqMvI=";
      };
      datetime = pkgs.fetchurl {
        url = "https://github.com/h1romas4/zellij-datetime/releases/latest/download/zellij-datetime.wasm";
        hash = "sha256-oVMh3LlFe4hcY9XmcEHz8pmodyf1aMvgDH31QEusEEE=";
      };
      zellijForgot = pkgs.fetchurl {
        url = "https://github.com/karimould/zellij-forgot/releases/download/0.4.2/zellij_forgot.wasm";
        hash = lib.faskhash;
      };
    };
  in {
    programs.zellij = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      attachExistingSession = true;
      settings = {
        web_server = true;
        web_server_ip = "0.0.0.0";
        web_server_port = 8088;
        # scrollback_editor = "${lib.getExe config.programs.helix.package}";

        show_startup_tips = false;
        web_server_cert = "${config.home.homeDirectory}/.certs/zellij.pem";
        web_server_key = "${config.home.homeDirectory}/.certs/zellij-key.pem";
        web_client = {
          font = "JetBrains Mono";
        };
      };
      extraConfig =
        # kdl
        ''
          plugins {
              room location="file:${zellijPlugins.room}"
              vimZellijNavigator location="file:${zellijPlugins.vimZellijNavigator}"
              harpoon location="file:${zellijPlugins.harpoon}"
              zellijForgot location="file:${zellijPlugins.zellijForgot}"
          }
          layout {
              pane size=1 borderless=true {
                  plugin location="file:${zellijPlugins.datetime}"
              }
              pane size=1 borderless=true {
                  plugin location="zellij:tab-bar"
              }
              pane
              pane size=1 borderless=true {
                  plugin location="zellij:status-bar"
              }
          }
          keybinds {
              pane {
                  bind "Ctrl y" {
                      LaunchOrFocusPlugin "harpoon" {
                          floating true
                          move_to_focused_tab true
                      }
                  }
              }
              tab {
                  bind "Ctrl y" {
                      LaunchOrFocusPlugin "room" {
                          floating true
                          ignore_case true
                          quick_jump true
                      }
                  }
                  bind "Shift h" {
                      MoveTab "Left"
                  }
                  bind "Shift l" {
                      MoveTab "Right"
                  }
              }
              shared_except "locked" {
                  bind "Ctrl /" {
                      LaunchOrFocusPlugin "file:~/zellij-plugins/zellij_forgot.wasm" {
                          LOAD_ZELLIJ_BINDINGS "false"
                          "buy eggs" "5x"
                          "learn rust" "5h"
                          "clean up code" "tomorrow"
                          floating true
                      }
                  }
                  bind "Ctrl h" {
                      MessagePlugin "vimZellijNavigator" {
                          name "move_focus_or_tab"
                          payload "left"
                          // Plugin Configuration
                          move_mod "ctrl"
                          // Optional, should be added on every move command if changed.
                          use_arrow_keys "false"
           // Optional, uses arrow keys instead of hjkl. Should be added to every command where you want to use it.
                      }
                  }
                  bind "Ctrl j" {
                      MessagePlugin "vimZellijNavigator" {
                          name "move_focus"
                          payload "down"
                          move_mod "ctrl"
                          use_arrow_keys "false"
                      }
                  }
                  bind "Ctrl k" {
                      MessagePlugin "vimZellijNavigator" {
                          name "move_focus"
                          payload "up"
                          move_mod "ctrl"
                          use_arrow_keys "false"
                      }
                  }
                  bind "Ctrl l" {
                      MessagePlugin "vimZellijNavigator" {
                          name "move_focus_or_tab"
                          payload "right"
                          move_mod "ctrl"
                          // Optional, should be added on every command if you want to use it
                          use_arrow_keys "false"
                      }
                  }
                  bind "Alt h" {
                      MessagePlugin "vimZellijNavigator" {
                          name "resize"
                          payload "left"
                          resize_mod "alt"
                      }
                  }
                  bind "Alt j" {
                      MessagePlugin "vimZellijNavigator" {
                          name "resize"
                          payload "down"
                          resize_mod "alt"
                      }
                  }
                  bind "Alt k" {
                      MessagePlugin "vimZellijNavigator" {
                          name "resize"
                          payload "up"
                          resize_mod "alt"
                      }
                  }
                  bind "Alt l" {
                      MessagePlugin "vimZellijNavigator" {
                          name "resize"
                          payload "right"
                          resize_mod "alt"
                      }
                  }
              }
          }
        '';
    };
  };
}
