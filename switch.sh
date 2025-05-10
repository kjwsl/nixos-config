#!/usr/bin/env bash

set -euo pipefail

SCRIPT_PATH=$(dirname -- "${BASH_SOURCE[0]}")
DEBUG=1

# Detect system type
SYSTEM_TYPE=$(uname -s)
HOSTNAME=$(hostname -s)

debug() {
    if [ -n "$DEBUG" ]; then
        echo "$@"
    fi
}

# Function to display menu
show_menu() {
    echo "1) Home"
    if [ "$SYSTEM_TYPE" = "Darwin" ]; then
        echo "2) Darwin (macOS)"
    else
        echo "2) Darwin (Not available on this system)"
    fi
    if [ "$SYSTEM_TYPE" = "Linux" ]; then
        echo "3) NixOS"
    else
        echo "3) NixOS (Not available on this system)"
    fi
    echo "4) Quit"
}

# Function to handle NixOS switch
handle_nixos() {
    if [ "$SYSTEM_TYPE" != "Linux" ]; then
        echo "Error: NixOS is only available on Linux systems"
        return 1
    fi
    
    echo "Build Command: sudo nixos-rebuild build --flake .#default"
    echo "Switch Command: sudo nixos-rebuild switch --flake .#default"
    
    read -p "Do you want to build first? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Building with command: sudo nixos-rebuild build --flake .#default"
        sudo nixos-rebuild build --flake .#default
        if [ $? -eq 0 ]; then
            echo "Build successful!"
            read -p "Do you want to switch now? (y/N) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "Switching with command: sudo nixos-rebuild switch --flake .#default"
                sudo nixos-rebuild switch --flake .#default
            fi
        else
            echo "Build failed"
            exit 1
        fi
    else
        echo "Switching with command: sudo nixos-rebuild switch --flake .#default"
        sudo nixos-rebuild switch --flake .#default
    fi
}

# Function to handle Home Manager switch
handle_home() {
    echo "Build Command: home-manager build --flake .#default"
    echo "Switch Command: home-manager switch --flake .#default"
    
    read -p "Do you want to build first? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Building with command: home-manager build --flake .#default"
        home-manager build --flake .#default
        if [ $? -eq 0 ]; then
            echo "Build successful!"
            read -p "Do you want to switch now? (y/N) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "Switching with command: home-manager switch --flake .#default"
                home-manager switch --flake .#default
            fi
        else
            echo "Build failed"
            exit 1
        fi
    else
        echo "Switching with command: home-manager switch --flake .#default"
        home-manager switch --flake .#default
    fi
}

# Function to handle Darwin switch
handle_darwin() {
    if [ "$SYSTEM_TYPE" != "Darwin" ]; then
        echo "Error: Darwin configuration is only available on macOS systems"
        return 1
    fi

    echo "Build Command: darwin-rebuild build --flake .#$HOSTNAME"
    echo "Switch Command: darwin-rebuild switch --flake .#$HOSTNAME"
    
    read -p "Do you want to build first? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Building with command: darwin-rebuild build --flake .#$HOSTNAME"
        darwin-rebuild build --flake .#$HOSTNAME
        if [ $? -eq 0 ]; then
            echo "Build successful!"
            read -p "Do you want to switch now? (y/N) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "Switching with command: darwin-rebuild switch --flake .#$HOSTNAME"
                darwin-rebuild switch --flake .#$HOSTNAME
            fi
        else
            echo "Build failed"
            exit 1
        fi
    else
        echo "Switching with command: darwin-rebuild switch --flake .#$HOSTNAME"
        darwin-rebuild switch --flake .#$HOSTNAME
    fi
}

# Main menu loop
while true; do
    show_menu
    read -p "Choose Platform: " choice
    case $choice in
        1)
            handle_home
            ;;
        2)
            handle_darwin
            ;;
        3)
            handle_nixos
            ;;
        4)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
done

