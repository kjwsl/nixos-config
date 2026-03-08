# OpenCode AI coding agent.
# Contributes to flake.modules.homeManager.base.
{...}: {
  flake.modules.homeManager.base = {...}: {
    programs.opencode = {
      enable = true;
      settings = {
        model = "github-copilot/claude-sonnet-4-5";
        autoupdate = false;
      };
    };
  };
}
