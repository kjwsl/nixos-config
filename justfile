# https://just.systems

set shell := ["nu", "-c"]

# Show available commands
default:
    just --list

# Apply system configuration (NixOS/macOS with integrated home-manager)
system action="switch":
    nu helper.nu system {{action}}

# Apply home-manager only (for non-NixOS systems)
home platform="linux":
    nu helper.nu home {{platform}}

# Build system configuration without applying
build-system:
    nu helper.nu system build

# Test system configuration
test-system:
    nu helper.nu system test

# Legacy commands for compatibility
linux:
    nu helper.nu home linux

darwin:
    nu helper.nu home darwin

termux:
    nu helper.nu home termux

# Show system information
info:
    nu helper.nu info

# Fix home-manager conflicts (if needed)
conflict:
    #!/usr/bin/env bash
    set -e
    
    if nix profile list | grep -q home-manager-path; then
      nix profile remove home-manager-path || true
    fi
