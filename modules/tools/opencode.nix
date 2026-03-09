# OpenCode AI coding agent.
# Contributes to flake.modules.homeManager.base.
{...}: {
  flake.modules.homeManager.base = {config, ...}: {
    programs.opencode = {
      enable = true;

      # Global rules loaded into every session.
      rules = ''
        # Global OpenCode Rules

        ## General
        - Never suppress TypeScript errors with `as any`, `@ts-ignore`, or `@ts-expect-error`
        - Never commit changes unless explicitly asked to
        - Never leave code in a broken state after failed fix attempts
        - Fix root causes, not symptoms — no shotgun debugging

        ## Git Safety
        - Never force push to main/master
        - Never amend a commit that has been pushed to remote
        - Always ask before `git push` and `sudo` commands
      '';

      # Custom slash commands available in any session.
      commands = {
        pr = ''
          Create a pull request for the current branch.

          1. Run `git log main..HEAD --oneline` to summarize commits
          2. Run `git diff main...HEAD --stat` to show changed files
          3. Write a clear PR title (imperative mood, ≤72 chars) and a body with:
             - ## Summary (2-4 bullet points of what changed and why)
             - ## Testing (how to verify)
          4. Run `gh pr create --title "<title>" --body "<body>"` and return the PR URL
        '';

        nixos-rebuild = ''
          Rebuild and switch to the NixOS/nix-darwin configuration in the current repo.

          1. Run `nix flake check` to catch syntax errors first — abort if it fails
          2. Detect the hostname with `hostname` and find the matching host config
          3. On macOS: run `darwin-rebuild switch --flake .#<hostname>`
             On NixOS: run `sudo nixos-rebuild switch --flake .#<hostname>`
          4. Report any build failures with the relevant log lines
        '';

        nix-fmt = ''
          Format all Nix files in the repository.

          Run `nix fmt` from the repo root, then show which files changed with `git diff --name-only`.
        '';
      };

      settings = {
        model = "github-copilot/claude-sonnet-4-5";
        autoupdate = false;
        plugin = [
          "opencode-antigravity-auth@latest"
          "opencode-gemini-auth@latest"
          "oh-my-opencode"
        ];

        # MCP servers — tools available to every session.
        mcp = {
          serena = {
            type = "local";
            # Uses project-from-cwd so it auto-detects the active repo.
            command = [
              "${config.home.homeDirectory}/.local/share/uv/tools/serena-agent/bin/serena"
              "start-mcp-server"
              "--project-from-cwd"
              "--context"
              "desktop-app"
            ];
          };
          context7 = {
            type = "local";
            command = ["npx" "-y" "@context7/mcp"];
          };
          playwright = {
            type = "local";
            command = ["npx" "-y" "@playwright/mcp"];
          };
          filesystem = {
            type = "local";
            command = ["npx" "-y" "@modelcontextprotocol/server-filesystem" config.home.homeDirectory];
          };
        };

        # Safety permissions — block destructive commands, prompt for risky ones.
        permission = {
          bash = {
            "git push --force*" = "deny";
            "git push -f*" = "deny";
            "rm -rf /*" = "deny";
            "rm -rf ~*" = "deny";
            "sudo rm -rf*" = "deny";
            "sudo*" = "ask";
            "git push*" = "ask";
          };
        };

        provider = {
          google = {
            models = {
              "antigravity-gemini-3-pro" = {
                name = "Gemini 3 Pro (Antigravity)";
                limit = {
                  context = 1048576;
                  output = 65535;
                };
                modalities = {
                  input = ["text" "image" "pdf"];
                  output = ["text"];
                };
                variants = {
                  low = {thinkingLevel = "low";};
                  high = {thinkingLevel = "high";};
                };
              };
              "antigravity-gemini-3.1-pro" = {
                name = "Gemini 3.1 Pro (Antigravity)";
                limit = {
                  context = 1048576;
                  output = 65535;
                };
                modalities = {
                  input = ["text" "image" "pdf"];
                  output = ["text"];
                };
                variants = {
                  low = {thinkingLevel = "low";};
                  high = {thinkingLevel = "high";};
                };
              };
              "antigravity-gemini-3-flash" = {
                name = "Gemini 3 Flash (Antigravity)";
                limit = {
                  context = 1048576;
                  output = 65536;
                };
                modalities = {
                  input = ["text" "image" "pdf"];
                  output = ["text"];
                };
                variants = {
                  minimal = {thinkingLevel = "minimal";};
                  low = {thinkingLevel = "low";};
                  medium = {thinkingLevel = "medium";};
                  high = {thinkingLevel = "high";};
                };
              };
              "antigravity-claude-sonnet-4-6" = {
                name = "Claude Sonnet 4.6 (Antigravity)";
                limit = {
                  context = 200000;
                  output = 64000;
                };
                modalities = {
                  input = ["text" "image" "pdf"];
                  output = ["text"];
                };
              };
              "antigravity-claude-opus-4-6-thinking" = {
                name = "Claude Opus 4.6 Thinking (Antigravity)";
                limit = {
                  context = 200000;
                  output = 64000;
                };
                modalities = {
                  input = ["text" "image" "pdf"];
                  output = ["text"];
                };
                variants = {
                  low = {thinkingConfig = {thinkingBudget = 8192;};};
                  max = {thinkingConfig = {thinkingBudget = 32768;};};
                };
              };
              "gemini-2.5-flash" = {
                name = "Gemini 2.5 Flash (Gemini CLI)";
                limit = {
                  context = 1048576;
                  output = 65536;
                };
                modalities = {
                  input = ["text" "image" "pdf"];
                  output = ["text"];
                };
              };
              "gemini-2.5-pro" = {
                name = "Gemini 2.5 Pro (Gemini CLI)";
                limit = {
                  context = 1048576;
                  output = 65536;
                };
                modalities = {
                  input = ["text" "image" "pdf"];
                  output = ["text"];
                };
              };
              "gemini-3-flash-preview" = {
                name = "Gemini 3 Flash Preview (Gemini CLI)";
                limit = {
                  context = 1048576;
                  output = 65536;
                };
                modalities = {
                  input = ["text" "image" "pdf"];
                  output = ["text"];
                };
              };
              "gemini-3-pro-preview" = {
                name = "Gemini 3 Pro Preview (Gemini CLI)";
                limit = {
                  context = 1048576;
                  output = 65535;
                };
                modalities = {
                  input = ["text" "image" "pdf"];
                  output = ["text"];
                };
              };
              "gemini-3.1-pro-preview" = {
                name = "Gemini 3.1 Pro Preview (Gemini CLI)";
                limit = {
                  context = 1048576;
                  output = 65535;
                };
                modalities = {
                  input = ["text" "image" "pdf"];
                  output = ["text"];
                };
              };
              "gemini-3.1-pro-preview-customtools" = {
                name = "Gemini 3.1 Pro Preview Custom Tools (Gemini CLI)";
                limit = {
                  context = 1048576;
                  output = 65535;
                };
                modalities = {
                  input = ["text" "image" "pdf"];
                  output = ["text"];
                };
              };
            };
          };
        };
      };
    };
  };
}
