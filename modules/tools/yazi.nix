# Yazi terminal file manager.
# Contributes to flake.modules.homeManager.base.
{ ... }:
{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      programs.yazi = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        enableFishIntegration = true;
        enableNushellIntegration = true;
        shellWrapperName = "y";
        settings = {
          mgr = {
            show_hidden = true;
            show_symlink = true;
          };
          preview = {
            wrap = "yes";
          };
          opener = {
            play = [
              {
                run = "mpv %s";
                orphan = true;
              }
            ];
            edit = [
              {
                run = "$EDITOR %s";
                block = true;
                for = "unix";
              }
              {
                run = "%EDITOR% %s";
                block = true;
                for = "windows";
              }
            ];
            open = [
              {
                run = "xdg-open %s";
                for = "unix";
                desc = "Open with the default program";
              }
              {
                run = "open %s";
                for = "macos";
                desc = "Open with the default program";
              }
            ];
          };
        };
        plugins = {
          git = pkgs.yaziPlugins.git;
          jjui = pkgs.yaziPlugins.jjui;
          smart-enter = pkgs.yaziPlugins.smart-enter;
          drag = pkgs.yaziPlugins.drag;
          sudo = pkgs.yaziPlugins.sudo;
        };
        keymap = {
          mgr.prepend_keymap = [
            {
              on = [
                "g"
                "j"
              ];
              run = "plugin jjui";
              desc = "run jjui";
            }
            {
              on = "l";
              run = "plugin smart-enter";
              desc = "Enter the child directory, or open the file";
            }
            {
              on = [ "<C-d>" ];
              run = "plugin drag";
              desc = "Drag Files";
            }

            # sudo cp/mv
            {
              on = [
                "R"
                "p"
                "p"
              ];
              run = "plugin sudo -- paste";
              desc = "sudo paste";
            }

            # sudo cp/mv --force
            {
              on = [
                "R"
                "P"
              ];
              run = "plugin sudo -- paste --force";
              desc = "sudo paste";
            }

            # sudo mv
            {
              on = [
                "R"
                "r"
              ];
              run = "plugin sudo -- rename";
              desc = "sudo rename";
            }

            # sudo ln -s (absolute-path)
            {
              on = [
                "R"
                "p"
                "l"
              ];
              run = "plugin sudo -- link";
              desc = "sudo link";
            }

            # sudo ln -s (relative-path)
            {
              on = [
                "R"
                "p"
                "r"
              ];
              run = "plugin sudo -- link --relative";
              desc = "sudo link relative path";
            }

            # sudo ln
            {
              on = [
                "R"
                "p"
                "L"
              ];
              run = "plugin sudo -- hardlink";
              desc = "sudo hardlink";
            }

            # sudo touch/mkdir
            {
              on = [
                "R"
                "a"
              ];
              run = "plugin sudo -- create";
              desc = "sudo create";
            }

            # sudo trash
            {
              on = [
                "R"
                "d"
              ];
              run = "plugin sudo -- remove";
              desc = "sudo trash";
            }

            # sudo delete
            {
              on = [
                "R"
                "D"
              ];
              run = "plugin sudo -- remove --permanently";
              desc = "sudo delete";
            }

            # sudo chmod
            {
              on = [
                "R"
                "m"
              ];
              run = "plugin sudo -- chmod";
              desc = "sudo chmod";
            }
          ];

        };
        extraPackages = [
          pkgs.glow
          pkgs.ouch
          pkgs.ripdrag
        ];
      };
    };
}
