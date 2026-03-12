#!/usr/bin/env bash

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
SCRIPT_PATH="$REPO_DIR/setup.nu"

is_exe() {
    [ -x "$(command -v "$1")" ]
}

ensure_nix() {
    if ! is_exe nix; then
        local yn
        read -r -p "Nix is not installed. Install now? [y/N] " yn

        case $yn in
        y | Y) curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install ;;
        *) return 1 ;;
        esac

        echo "🛠️ Source nix in current shell..."
        if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
            # shellcheck source=/dev/null
            . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        elif [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
            # shellcheck source=/dev/null
            . "$HOME/.nix-profile/etc/profile.d/nix.sh"
        else
            echo "🔴 Source nix failed"
            return 1
        fi

        # Check for nix again
        if ! is_exe nix; then
            echo "🔴 Nix installation failed"
            return 1
        fi

        echo "🚀 Nix has been successfully installed"
    fi
}

ensure_script() {
    if [ ! -f "$SCRIPT_PATH" ]; then
        echo "🔴 Script not found at $SCRIPT_PATH"
        return 1
    elif [ ! -x "$SCRIPT_PATH" ]; then
        echo "🔴 Script at $SCRIPT_PATH is not executable"
        return 1
    fi
}

main() {
    if ! ensure_nix; then
        echo "Nix installation failed"
        return 1
    fi

    if ! ensure_script; then
        echo "Script installation failed"
        return 1
    fi

    exec nix develop .# --command nu "$SCRIPT_PATH" "$@"
}

main "$@" || exit 1
