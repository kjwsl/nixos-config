# Jujutsu VCS configuration.
# Contributes to flake.modules.homeManager.base.
{...}: {
  flake.modules.homeManager.base = {config, ...}: {
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
          editor = "nvim";
          default-command = "log";
        };
        diff.tool.difftastic.command = ["difft" "--color=always"];
        revset-aliases."HEAD" = "@-";
        aliases = {
          lg = ["log"];
          lga = ["log-all"];
          log-all = ["log" "-r" "all()"];
          df = ["diff"];
          b = ["bookmark"];
          n = ["new"];
        };
      };
    };
  };
}
