# NixOS Configuration

This repository contains my personal NixOS and macOS (via nix-darwin) configurations. It uses flakes for dependency management and includes configurations for both Linux and macOS systems.

## Directory Structure

```
.
├── flake.nix              # Main flake configuration
├── flake.lock            # Flake lock file
├── hosts/                # System-specific configurations
│   ├── nixos/           # NixOS configurations
│   │   ├── default/     # Default NixOS configuration
│   │   └── workmachine/ # Work machine configuration
│   └── darwin/          # macOS configurations
├── home/                 # Home Manager configurations
│   ├── modules/         # Reusable home-manager modules
│   ├── profiles/        # User profiles (desktop, laptop, etc.)
│   └── home.nix         # Main home-manager configuration
├── lib/                  # Custom library functions
├── nix/                  # Nix-specific configurations
│   ├── overlays/        # Custom overlays
│   └── pkgs/            # Custom packages
├── shells/              # Development shell configurations
├── sops/                # SOPS encrypted secrets
└── switch.py           # Helper script for applying configurations
```

## Prerequisites

- Nix with flakes enabled
- For macOS: nix-darwin
- For secrets management: SOPS

## Usage

### Linux (NixOS)

To apply the configuration:

```bash
# Using the Python script
./switch.py

# Or using the shell script
./switch.sh
```

### macOS

To apply the configuration:

```bash
darwin-rebuild switch --flake .#rays-MacBook-Air
```

### Home Manager

To apply home-manager configurations:

```bash
# For Linux
home-manager switch --flake .#default

# For macOS
home-manager switch --flake .#mac
```

## Features

- Flake-based configuration management
- Cross-platform support (Linux and macOS)
- Home Manager integration
- SOPS for secrets management
- Custom development shells
- Modular configuration structure

## Configuration Details

### Systems

- Linux (NixOS)
  - Default configuration
  - Work machine configuration
- macOS
  - MacBook Air configuration

### Inputs

- nixpkgs (unstable)
- home-manager
- nix-darwin
- flake-utils
- sops-nix
- neovim-nightly

## Maintenance

1. Update flake inputs:
```bash
nix flake update
```

2. Apply updates:
```bash
# For NixOS
sudo nixos-rebuild switch --flake .#default

# For macOS
darwin-rebuild switch --flake .#rays-MacBook-Air
```

## Notes

- Make sure to have the necessary permissions when applying system-wide changes
- Backup your data before making significant changes
- Review the configuration before applying it to your system 