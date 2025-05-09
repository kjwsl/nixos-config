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
├── devshell.toml          # Development environments (TOML format)
├── shell.nix              # Development environments (Nix format)
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

### Development Environments
The configuration provides two ways to manage development environments:

#### 1. Using devshell.toml (Modern Approach)
```bash
# Install devshell
nix-env -iA nixpkgs.devshell

# Enter a development environment
devshell enter python    # Python development
devshell enter nodejs    # Node.js development
devshell enter rust      # Rust development
devshell enter web       # Web development
devshell enter system    # System development
devshell enter database  # Database development
devshell enter ml        # Machine Learning
devshell enter devops    # DevOps
```

Available environments include:
- Python Development (pytest, black, flake8, mypy, etc.)
- Node.js Development (TypeScript, ESLint, Prettier, etc.)
- Rust Development (rustfmt, clippy, rust-analyzer, etc.)
- Go Development (gopls, delve, golangci-lint, etc.)
- Web Development (Node.js, browsers, testing tools)
- System Development (gcc, gdb, valgrind, etc.)
- Database Development (PostgreSQL, MySQL, Redis, etc.)
- Machine Learning (NumPy, Pandas, TensorFlow, PyTorch, etc.)
- DevOps (Docker, Kubernetes, Terraform, etc.)

Each environment includes:
- Language-specific tools
- Development utilities
- Testing frameworks
- Linters and formatters
- Common development tools

#### 2. Using shell.nix (Traditional Approach)
```bash
# Enter a development environment
nix-shell shell.nix -A python    # Python development
nix-shell shell.nix -A nodejs    # Node.js development
nix-shell shell.nix -A rust      # Rust development
nix-shell shell.nix -A web       # Web development
nix-shell shell.nix -A system    # System development
nix-shell shell.nix -A database  # Database development
nix-shell shell.nix -A ml        # Machine Learning
nix-shell shell.nix -A devops    # DevOps
```

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

## Quick Start Guide

### 1. Initial Setup
```bash
# Install Nix if not already installed
sh <(curl -L https://nixos.org/nix/install) --daemon

# Enable flakes (if not already enabled)
echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
```

### 2. Choose Your Desktop Environment
```nix
# Edit home/home.nix and set your preferred desktop environment
ray.home.profiles.desktop-environments.active = "gnome"; # or "hyprland"
```

### 3. Select Your Profile
```nix
# Edit home/home.nix and set your profile
ray.home.profiles.active = "desktop"; # or "development", "work"
```

### 4. Development Environment Setup
Choose one of two methods:

#### Option A: Using devshell (Recommended)
```bash
# Install devshell
nix-env -iA nixpkgs.devshell

# Enter a development environment
devshell enter python    # For Python development
```

#### Option B: Using shell.nix
```bash
# Enter a development environment
nix-shell shell.nix -A python    # For Python development
```

### 5. Common Tasks

#### Switching Desktop Environments
```bash
# Edit home/home.nix
ray.home.profiles.desktop-environments.active = "hyprland";
# Rebuild and activate
nix build .#homeConfigurations.default.activationPackage
./result/activate
```

#### Adding New Packages
```nix
# Edit home/home.nix
home.packages = with pkgs; [
  # Add your packages here
  firefox
  vscode
];
```

#### Creating a New Development Environment
1. Edit `devshell.toml` or `shell.nix`
2. Add your new environment configuration
3. Use `devshell enter your-env` or `nix-shell shell.nix -A your-env`

### 6. Troubleshooting

#### Common Issues
1. **Package not found**
   - Check if the package exists in nixpkgs
   - Add it to your overlays if needed

2. **Environment not working**
   - Ensure you're in the correct directory
   - Check if all dependencies are installed
   - Try rebuilding the environment

3. **Desktop Environment issues**
   - Check the logs: `journalctl -b`
   - Verify your graphics drivers
   - Ensure Wayland/X11 is properly configured

#### Getting Help
- Check the [NixOS Wiki](https://nixos.wiki)
- Join the [NixOS Discourse](https://discourse.nixos.org)
- Visit the [NixOS IRC Channel](irc://irc.libera.chat/#nixos)

### 7. Next Steps
1. Explore the available modules in `home/modules/`
2. Customize your profile in `home/profiles/`
3. Add your own overlays in `overlays/`
4. Contribute to the project!

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

### Customizing Development Environments
1. Edit `devshell.toml` or `shell.nix` to add/modify environments
2. Add new packages to existing environments
3. Create new environment-specific scripts
4. Add custom commands for each environment

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 