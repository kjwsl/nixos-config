# Git global hooks via init.templateDir.
# Seeds every new clone / git-init with a pre-push secret scanner.
# Contributes to flake.modules.homeManager.base.
{...}: {
  flake.modules.homeManager.base = {
    pkgs,
    lib,
    ...
  }: {
    # Place the template hook so `git init` / `git clone` picks it up.
    home.file.".config/git/templates/hooks/pre-push" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        RED='\033[0;31m'
        YELLOW='\033[0;33m'
        GREEN='\033[0;32m'
        BOLD='\033[1m'
        NC='\033[0m'

        warn() { echo -e "''${YELLOW}''${BOLD}[WARN]''${NC}   $*" >&2; }
        ok()   { echo -e "''${GREEN}''${BOLD}[OK]''${NC}     $*"; }

        echo -e "''${BOLD}Running pre-push checks...''${NC}"

        # ── 1. Secret scan ──────────────────────────────────────────────────────
        echo "-> Scanning for secrets..."

        git diff HEAD~1..HEAD 2>/dev/null \
          | grep -E "^\+" \
          | grep -v "^+++" \
          > /tmp/prepush-diff || true

        check_pattern() {
          local label="$1"
          local pattern="$2"
          local hits
          hits=$(grep -E "$pattern" /tmp/prepush-diff 2>/dev/null || true)
          if [ -n "$hits" ]; then
            warn "Possible secret -- $label"
            echo "$hits" | head -3 | sed 's/^/    /' >&2
            return 1
          fi
          return 0
        }

        FOUND_SECRETS=0
        check_pattern "AWS access key"      'AKIA[0-9A-Z]{16}'                             || FOUND_SECRETS=1
        check_pattern "Google API key"      'AIza[0-9A-Za-z_-]{35}'                        || FOUND_SECRETS=1
        check_pattern "OpenAI key"          'sk-[a-zA-Z0-9]{32}'                           || FOUND_SECRETS=1
        check_pattern "GitHub PAT classic"  'ghp_[a-zA-Z0-9]{36}'                          || FOUND_SECRETS=1
        check_pattern "GitHub PAT fine"     'github_pat_[a-zA-Z0-9_]{20}'                  || FOUND_SECRETS=1
        check_pattern "Slack token"         'xox[bp]-[0-9A-Za-z-]+'                        || FOUND_SECRETS=1
        check_pattern "Private key"         'BEGIN (RSA|EC|DSA|OPENSSH) PRIVATE KEY'       || FOUND_SECRETS=1
        check_pattern "password ="          'password[[:space:]]*=[[:space:]]*"[^"]'       || FOUND_SECRETS=1

        rm -f /tmp/prepush-diff

        if [ "$FOUND_SECRETS" -eq 1 ]; then
          echo >&2
          echo -e "''${RED}''${BOLD}Secret scan failed.''${NC} Review the matches above." >&2
          echo "  False positive? Bypass: GIT_PUSH_NO_SECRET_SCAN=1 jj git push" >&2
          if [ "''${GIT_PUSH_NO_SECRET_SCAN:-0}" != "1" ]; then
            exit 1
          else
            warn "Secret scan bypassed via GIT_PUSH_NO_SECRET_SCAN=1"
          fi
        else
          ok "No secrets found"
        fi

        # ── 2. Nix flake check (only when flake.nix is present) ─────────────────
        if [ -f flake.nix ]; then
          echo "-> Checking flake evaluates..."
          if ! command -v nix &>/dev/null; then
            warn "nix not found, skipping flake check"
          else
            if ! nix flake check --no-build --keep-going 2>/tmp/nix-check-err; then
              NIX_ERRS=$(grep "^error:" /tmp/nix-check-err \
                | grep -v "Cannot build\|platform mismatch\|Build failed\|some errors were encountered\|^error:$" \
                || true)
              if [ -n "$NIX_ERRS" ]; then
                echo -e "''${RED}''${BOLD}Flake check found eval errors:''${NC}" >&2
                echo "$NIX_ERRS" >&2
                rm -f /tmp/nix-check-err
                exit 1
              fi
            fi
            rm -f /tmp/nix-check-err
            ok "Flake check passed"
          fi
        fi

        # ── 3. Chain to repo-local hooks ─────────────────────────────────────────
        REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || true)
        if [ -n "$REPO_ROOT" ]; then
          for candidate in "$REPO_ROOT/.githooks/pre-push" "$REPO_ROOT/.git/hooks/pre-push.local"; do
            if [ -x "$candidate" ]; then
              echo "-> Running repo-local hook: $candidate"
              "$candidate" "$@"
            fi
          done
        fi

        echo -e "''${GREEN}''${BOLD}All checks passed.''${NC} Pushing..."
      '';
    };

    # Point git at the template dir so new repos get the hook automatically.
    home.activation.setGitTemplateDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run ${pkgs.git}/bin/git config --global init.templateDir "$HOME/.config/git/templates" 2>/dev/null || true
    '';
  };
}
