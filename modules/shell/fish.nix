# Fish shell configuration.
# Contributes to flake.modules.homeManager.base.
{ ... }:
{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      programs.fish = {
        enable = true;
        interactiveShellInit =
          # fish
          ''
            # Disable greeting message
            set -g fish_greeting

            # Enable trasient prompt
            set -g fish_transient_prompt 1

            # vi key bindings
            fish_vi_key_bindings

            # ntfy.sh notifications
            set -gx NTFY_TOPIC notify-3152210757
          '';

        functions = {
          tere =
            # fish
            ''
              set --local result (command tere $argv)
              [ -n "$result" ] && cd -- "$result"
            '';
          notify =
            # fish
            ''
                  set -l msg (test (count $argv) -gt 0; and string join " " $argv; or echo "Task completed")
                  set -l dir (string replace $HOME "~" $PWD)
                  curl -s \
                      -H "Title: 🔔 $hostname: Manual notification" \
                      -d "$msg

              Directory: $dir" \
                      "ntfy.sh/$NTFY_TOPIC" >/dev/null 2>&1 &
            '';
          __notify_on_long_command = {
            body =
              # fish
              ''
                # Skip for interactive editors and common long-running interactive tools
                set -l command_name (string split -m 1 " " $argv[1])[1]
                if contains $command_name nvim vi vim ssh hx btop
                    return
                end
                if test $CMD_DURATION -gt 30000
                    set -l secs (math "$CMD_DURATION / 1000")
                    set -l status_emoji (test $status -eq 0 && echo "✅" || echo "❌")
                    set -l status_text (test $status -eq 0 && echo "Success" || echo "Failed (exit $status)")
                    set -l cmd (string shorten -m 100 "$argv[1]")
                    set -l dir (string replace $HOME "~" $PWD)
                    set -l host $hostname
                    curl -s \
                        -H "Title: $status_emoji $host: Command finished" \
                        -d "$cmd

                      Status: $status_text
                      Duration: $secs seconds
                      Directory: $dir" \
                        "ntfy.sh/$NTFY_TOPIC" >/dev/null 2>&1 &
                end
              '';
            onEvent = "fish_postexec";
          };
        };
        plugins = [
          {
            name = "bass";
            src = pkgs.fishPlugins.bass;
          }
          {
            name = "plugin-git";
            src = pkgs.fishPlugins.plugin-git;
          }
          {
            name = "puffer";
            src = pkgs.fishPlugins.puffer;
          }
          {
            name = "sponge";
            src = pkgs.fishPlugins.sponge;
          }
          {
            name = "spark";
            src = pkgs.fishPlugins.spark;
          }
          {
            name = "nix-env.fish";
            src = fetchTarball {
              url = "https://github.com/lilyball/nix-env.fish/archive/refs/heads/master.tar.gz";
              sha256 = "069ybzdj29s320wzdyxqjhmpm9ir5815yx6n522adav0z2nz8vs4";
            };
          }
          {
            name = "replay.fish";
            src = fetchTarball {
              url = "https://github.com/jorgebucaran/replay.fish/archive/refs/heads/main.tar.gz";
              sha256 = "1n2xji4w5k1iyjsvnwb272wx0qh5jfklihqfz0h1a1bd3zp3sd2g";
            };
          }
          {
            name = "fish-abbreviation-tips";
            src = fetchTarball {
              url = "https://github.com/gazorby/fish-abbreviation-tips/archive/refs/heads/master.tar.gz";
              sha256 = "05b5qp7yly7mwsqykjlb79gl24bs6mbqzaj5b3xfn3v2b7apqnqp";
            };
          }
        ]
        ++ pkgs.lib.optionals (!pkgs.stdenv.isDarwin) [
          {
            name = "fzf-fish";
            src = pkgs.fishPlugins.fzf-fish;
          }
        ];
      };
    };
}
