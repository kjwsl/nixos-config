#!/usr/bin/env bash

set -euo pipefail

SCRIPT_PATH=$(dirname -- "${BASH_SOURCE[0]}")
DEBUG=1

debug() {
    if [ -n "$DEBUG" ]; then
        echo "$@"
    fi
}

platform_menu() {
    PS3="Choose Platform: "
    platform_options=("Home" "Darwin" "NixOS" "Quit")
    select opt in "${platform_options[@]}"; do
        case $opt in
            "Home")
                BUILD_CMD="nix run home-manager/master build -- --flake .#default"
                SWITCH_CMD="nix run home-manager/master switch -- --flake .#default"
                ;;
            "Darwin")
                BUILD_CMD="nix run nix-darwin build -- --flake .#rays-MacBook-Air"
                SWITCH_CMD="nix run nix-darwin switch -- --flake .#rays-MacBook-Air"
                ;;
            "NixOS")
                BUILD_CMD="nix run nixos-rebuild build -- --flake .#default"
                SWITCH_CMD="nix run nixos-rebuild switch -- --flake .#default"
                ;;
            "Quit")
                echo "Quitting..."
                exit 0
                ;;
            *) 
                echo "Invalid option $REPLY"
                continue
                ;;
        esac
        debug "Build Command: ${BUILD_CMD}"
        debug "Switch Command: ${SWITCH_CMD}"
        return 0
    done
}

build() {
    local build_cmd=$1
    debug "Building with command: ${build_cmd}"
    
    if ! eval "${build_cmd}"; then
        echo "Build failed"
        exit 1
    fi
}

commit() {
    local now
    now=$(date "+%Y-%m-%d %H:%M:%S")
    echo "Committing the changes..."
    if ! git commit -am "[${now}] Update system configuration"; then
        echo "Warning: Commit failed, but continuing..."
    fi
}

switch() {
    local switch_cmd=$1
    echo "Switching to the new configuration..."
    if ! eval "${switch_cmd}"; then
        echo "Switch failed"
        exit 1
    fi
}

main() {
    local BUILD_CMD
    local SWITCH_CMD
    
    platform_menu
    build "${BUILD_CMD}"
    commit
    switch "${SWITCH_CMD}"
    echo "Done!"
}

main

