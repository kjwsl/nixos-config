# Yazi terminal file manager.
# Contributes to flake.modules.homeManager.base.
{ ... }:
{
  flake.modules.homeManager.base =
    { ... }:
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
      };
    };
}
