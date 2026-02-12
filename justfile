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
    nix run home-manager -- build --impure --flake .#linux
    result/activate

darwin:
    nix run home-manager -- build --impure --flake .#darwin
    result/activate

termux:
    nix run home-manager -- build --impure --flake .#termux
    result/activate
