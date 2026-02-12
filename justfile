# https://just.systems

_default:
    just -l

conflict:
    #!/usr/bin/env bash
    set -e

    if nix profile list | grep -q home-manager-path; then
      nix profile remove home-manager-path || true
    fi


linux:
    nix run home-manager -- switch --flake .#ray-linux -b backup

darwin:
    nix run home-manager -- switch --flake .#ray-darwin -b backup

termux:
    nix run home-manager -- switch --flake .#ray-termux -b backup
