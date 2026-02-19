# https://just.systems

default:
    echo 'Hello, world!'

conflict:
    #!/usr/bin/env bash
    set -e

    if nix profile list | grep -q home-manager-path; then
      nix profile remove home-manager-path || true
    fi


linux:
    nix run home-manager -- build --flake .#ray-linux
    result/activate

darwin:
    nix run home-manager -- switch --flake .#ray-darwin -b backup --force

termux:
    nix run home-manager -- build --flake .#ray-termux
    result/activate
