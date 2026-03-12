#!/usr/bin/env bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SETUP_SCRIPT="$SCRIPT_DIR/setup.nu"

main() {
    if [ ! -f "$SETUP_SCRIPT" ]; then
        echo "Could not find setup script: $SETUP_SCRIPT"
        return 1
    fi

    if [ ! -x "$(command -v nix)" ]; then
        echo "Could not find nix"
        return 1
    fi

    exec nix develop .# --command nu "$SETUP_SCRIPT" "$@" 2>&1 
}

main "$@" || exit 1
