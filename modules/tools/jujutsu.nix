# Jujutsu VCS configuration.
# Contributes to flake.modules.homeManager.base.
{ ... }:
{
  flake.modules.homeManager.base =
    { config, ... }:
    {
      programs.jujutsu = {
        enable = true;
        settings = {
          user = {
            name = config.home.username;
            email = "kjwdev01@gmail.com";
          };
          ui = {
            diff-formatter = ":git";
            pager = "delta";
            color = "always";
            editor = "nvim";
            default-command = "log";
          };
          fsmonitor = {
            backend = "watchman";
          };
          git = {
            default-branch = "main";
            # Automatically abandon commits that are no longer reachable in Git
            abandon-locally-abandoned = true;
            # Ensure we don't try to push to read-only remote branches
            push-bookmark-prefix = "jj/";
          };
          merge-tools = {
            nvim = {
              merge-args = [
                "-d"
                "$left"
                "$right"
                "$output"
              ];
            };
            codediff = {
              command = [ "nvim" ];
              merge-args = [
                "$output"
                "-c"
                "CodeDiff merge \"$output\""
              ];
            };
          };
          diff.tool.difftastic.command = [
            "difft"
            "--color=always"
          ];
          revset-aliases."HEAD" = "@-";
          aliases = {
            lg = [ "log" ];
            lga = [ "log-all" ];
            log-all = [
              "log"
              "-r"
              "all()"
            ];
            df = [ "diff" ];
            dfp = [
              "diff"
              "-r"
              "@-"
            ];
            sl = [ "show-last" ];
            show-last = [
              "show"
              "-r"
              "@-"
            ];
            b = [ "bookmark" ];
            n = [ "new" ];
          };
          snapshot = {
            auto-update-stale = true;
          };
        };
      };
    };
}
