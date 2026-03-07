#!/usr/bin/env bash

set -eu

help() {
    echo "Ray's helper script for installing nix"
    echo "\thelp: Show this help message"
    echo "\tinstall: Install nix"
}

install_nix-installer() {
    curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install
}

main() {
    # if no args, show help
    if [ "$#" -eq 0 ]; then
        help
    fi

    # switch
    local cmd="$1"

    case "$cmd" in
        "install")
            if ! install_nix-installer; then
                echo "Failed to install Nix installer"
                return 1
            fi

            if [ ! -x /nix/nix-installer ]; then
                echo "/nix/nix-installer not found"
                return 1
            fi

            if ! /nix/nix-installer install; then
                echo "Failed to install Nix"
                return 1
            fi
            return 0
            ;;
        "help")
            help
            return 0
            ;;
        *)
            echo "Unknown command: $cmd"
            help
            return 1
            ;;
    esac
}

main "$@" || exit 1
