# Jujutsu VCS configuration.
# Contributes to flake.modules.homeManager.base.
{ config, ... }:
let
  email = config.email;
in
{
  flake.modules.homeManager.base =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      programs.jujutsu = {
        enable = true;
        settings = {
          user = {
            name = config.home.username;
            inherit email;
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
              # diff-args: Opens a vertical split comparing the two states.
              diff-args = [
                "-d"
                "$left"
                "$right"
              ];

              # edit-args: Opens a vertical split where you can modify the $right file.
              edit-args = [
                "-d"
                "$left"
                "$right"
              ];

              # merge-args: Opens a 3-way split (Local, Output, Remote). You resolve conflicts in $output.
              merge-args = [
                "-d"
                "$left"
                "$output"
                "$right"
              ];
            };
            nvim-ext = {
              program = "nvim";
              edit-args = [
                "-c"
                "DiffEditor $left $right $output"
              ];
              diff-args = [
                "-c"
                "DiffEditor $left $right $output"
              ];
              merge-args = [
                "-c"
                "DiffEditor $left $right $output"
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
