# NixOS Configuration

A modular and extensible NixOS configuration with support for multiple desktop environments, development tools, and custom package overlays.

## Structure

```
.
├── home/                    # Home Manager configuration
│   ├── home.nix            # Main home configuration
│   ├── modules/            # Home Manager modules
│   │   ├── apps/          # Application modules
│   │   ├── shell/         # Shell configuration modules
│   │   └── dev/           # Development tools modules
│   └── profiles/          # User profiles
│       ├── desktop.nix    # Desktop profile
│       ├── development.nix # Development profile
│       ├── work.nix       # Work profile
│       └── desktop-environments/ # DE-specific configurations
│           ├── hyprland.nix
│           └── gnome.nix
├── overlays/               # Custom package overlays
│   ├── default.nix        # Main overlay configuration
│   ├── dev-tools.nix      # Development tools overlays
│   ├── desktop-environments.nix # DE-specific overlays
│   └── applications.nix   # Application overlays
├── hosts/                  # Host-specific configurations
│   ├── nixos/             # NixOS hosts
│   └── darwin/            # macOS hosts
└── flake.nix              # Main flake configuration
```

## Features

### Desktop Environments
- **Hyprland**: Modern Wayland compositor with dynamic workspaces
- **GNOME**: Traditional desktop environment with custom extensions
- Support for KDE and XFCE (configurable)

### Profiles
- **Desktop**: Full desktop experience with multimedia and gaming
- **Development**: Development-focused setup with tools and IDEs
- **Work**: Professional work environment with communication tools

### Overlays
Custom package modifications and groupings:

#### Development Tools
- Node.js version management
- Python package customizations
- Rust toolchain configuration
- Development utilities package

#### Desktop Environments
- GNOME Shell customizations
- Hyprland patches and configurations
- Desktop utilities package

#### Applications
- Firefox with custom policies
- VSCode/Cursor with specific extensions
- Custom application packages
- Version overrides

## Usage

### Switching Desktop Environments
```nix
# In home.nix
ray.home.profiles.desktop-environments.active = "hyprland"; # or "gnome"
```

### Enabling Profiles
```nix
# In home.nix
ray.home.profiles.active = "development"; # or "desktop", "work"
```

### Using Custom Packages
```nix
# In home.nix
home.packages = with pkgs; [
  pkgs.dev-tools      # Custom development tools
  pkgs.desktop-utils  # Desktop utilities
  pkgs.my-apps        # Custom applications
];
```

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/nixos-config.git
cd nixos-config
```

2. Build the configuration:
```bash
nix build .#homeConfigurations.default.activationPackage
```

3. Activate the configuration:
```bash
./result/activate
```

## Customization

### Adding New Overlays
1. Create a new overlay file in `overlays/`
2. Add the overlay to `overlays/default.nix`
3. Use the overlay in your configuration

### Creating New Profiles
1. Add a new profile file in `home/profiles/`
2. Update `home/profiles/default.nix`
3. Enable the profile in `home/home.nix`

### Modifying Desktop Environments
1. Edit the corresponding DE file in `home/profiles/desktop-environments/`
2. Add custom overlays in `overlays/desktop-environments.nix`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 