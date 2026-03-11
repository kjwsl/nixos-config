# Nushell configuration.
# Contributes to flake.modules.homeManager.base.
{...}: {
  flake.modules.homeManager.base = {pkgs, ...}: {
    programs.nushell = {
      enable = true;
      extraEnv = ''
        # Source home-manager session variables
        let hm_vars = ("~/.nix-profile/etc/profile.d/hm-session-vars.sh" | path expand)
        if ($hm_vars | path exists) {
          # Capture variables from sh after sourcing
          let vars = (sh -c $"source ($hm_vars) && env" | lines)
          
          # Iterate and load-env
          for var in $vars {
            let parts = ($var | split row "=")
            if ($parts | length) >= 2 {
              let name = $parts.0
              let value = ($parts | slice 1.. | str join "=")
              
              # Skip protected/redundant variables
              if not ($name in ["_" "PATH" "PWD" "PROMPT_COMMAND" "PROMPT_INDICATOR" "PROMPT_INDICATOR_VI_INSERT" "PROMPT_INDICATOR_VI_NORMAL" "PROMPT_MULTILINE_INDICATOR" "SHLVL" "TERM" "LS_COLORS"]) {
                load-env { ($name): $value }
              }
            }
          }
        }
      '';
      settings = {
        show_banner = false;
        completions.external = {
          enable = true;
          max_results = 200;
        };
      };
      plugins = with pkgs.nushellPlugins; [
        formats
        skim
        semver
        highlight
        gstat
        query
      ];
    };
  };
}
