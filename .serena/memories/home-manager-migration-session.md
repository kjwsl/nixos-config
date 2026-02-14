# Home-Manager Dotfiles Migration Session

## Session Date
2025-02-14

## Project Context
- **Repository**: `/Users/ray/repos/home-manager`
- **Original Dotfiles**: `/Users/ray/dotfiles` (chezmoi-managed)
- **Goal**: Migrate dotfiles to Nix/home-manager for declarative configuration

## Problem Identified
User's dotfiles were previously managed with chezmoi at `/Users/ray/dotfiles`. An AI assistant ("openclaw") attempted migration but created incorrect paths in `modules/dotfiles.nix` that referenced non-existent relative paths (`../dotfiles/` instead of absolute path to `/Users/ray/dotfiles`).

## Session Accomplishments

### 1. Full Dotfiles Migration to Home-Manager ✅

**Migrated Configurations:**
- **Fish Shell** (`modules/shell.nix`): Converted Fisher plugins to HM native, migrated all aliases, functions (envsource, vf, zf, smartdd, notify), and config.fish initialization
- **Starship** (`starship.toml`): Copied original custom config, using HM's `pkgs.lib.importTOML`
- **Tmux** (`config/tmux/` + `modules/multiplexers.nix`): Preserved TPM setup, custom scripts, Ctrl-s prefix via raw config files
- **Zellij** (`modules/multiplexers.nix`): Configured with HM native module
- **WezTerm** (`config/wezterm/` + `modules/terminals.nix`): Preserved Lua config with modules, background image, OS-specific settings

**Approach Used:**
- **Hybrid strategy**: HM native modules where appropriate (fish, git, simple configs)
- **Raw config files**: For complex setups (tmux with TPM, wezterm Lua modules)
- **Copied configs to repo**: Created `config/` directory to make repo standalone

### 2. Profile-Based Setup Created ✅

**Profile Structure:**
```
base.nix → minimal.nix
         → development.nix → work.nix
                          → personal.nix
```

**Available Profiles:**
- `minimal`: Shell + git + 10 basic tools
- `development`: Full dev environment (80+ packages)
- `work`: Development + work-specific tools
- `personal`: Development + personal tools

**Usage:**
```bash
home-manager switch --flake .#darwin-development
home-manager switch --flake .#darwin-minimal
home-manager switch --flake .#darwin-work
```

### 3. Alternative Approaches Explored

**User Question:** "Is home-manager really the best approach?"

**Approaches Discussed:**
1. **Home-Manager** (current): Full-featured, complex, generations/rollback
2. **Flake Apps**: Simple install scripts, no package management
3. **Pure Packages** (like tmux-powerkit): Dotfiles as Nix packages
4. **devShells**: Modern, per-project, simple (RECOMMENDED)
5. **Hybrid**: Packages for dotfiles + devShells for tools

**Key Insight:** For user's use case (single user, macOS, dotfiles + tools + profiles), **devShells approach is simpler and more modern** than full home-manager.

## Files Created

### Core Modules
- `modules/shell.nix`: Fish with plugins, aliases, functions
- `modules/starship.nix`: Starship prompt config
- `modules/git.nix`: Git configuration
- `modules/editors.nix`: Neovim setup
- `modules/multiplexers.nix`: Tmux + Zellij
- `modules/terminals.nix`: WezTerm configuration
- `modules/tools.nix`: CLI tools bundle

### Profiles
- `profiles/base.nix`: Shared baseline
- `profiles/minimal.nix`: Minimal setup
- `profiles/development.nix`: Full dev environment
- `profiles/work.nix`: Work-specific
- `profiles/personal.nix`: Personal setup

### Config Files
- `config/tmux/`: tmux.conf, plugins, scripts, nvim integration
- `config/wezterm/`: wezterm.lua, utils.lua, modules/, bg.jpg
- `starship.toml`: Custom starship configuration

### Examples (for reference)
- `flake-apps-example.nix`: Flake apps approach example
- `flake-clean.nix`: Pure packages approach (like tmux-powerkit)
- `flake-devshell.nix`: devShells approach (recommended alternative)

## Updated flake.nix Structure

```nix
homeConfigurations = {
  # macOS profiles
  darwin = development profile (default)
  darwin-minimal = minimal profile
  darwin-development = full dev
  darwin-work = work setup
  darwin-personal = personal setup
  
  # Linux profiles
  linux = development (default)
  linux-minimal, linux-development, linux-work, linux-personal
  
  # Termux profiles
  termux = minimal (default)
  termux-development
}
```

## Key Learnings

### Technical Decisions
1. **Tmux + WezTerm**: Used raw config files because:
   - TPM (Tmux Plugin Manager) not supported by HM
   - Complex Lua modules in WezTerm
   - Custom scripts and sourced files
   
2. **Fish Plugins**: Some plugins omitted due to hash mismatches (done, puffer-fish, sponge, fzf.fish, plugin-git). Can be added with correct hashes later or installed via Fisher.

3. **Profile Inheritance**: Profiles use imports chain (base → minimal → development → work/personal) for DRY configuration.

### Approach Trade-offs

**Home-Manager Pros:**
- Declarative package management
- Generations and rollback
- Type-safe module system
- Cross-platform support

**Home-Manager Cons:**
- Complex for simple use cases
- Heavy dependency
- Learning curve
- Some configs don't fit the model

**devShells Alternative:**
- Simpler, more modern
- Per-project environments
- Auto-load with direnv
- Standard for Nix developers
- But: No system-wide installation, no rollback

## Current State

### Build Status
✅ All profiles build successfully:
- `darwin-minimal`: 13 packages
- `darwin-development`: 80+ packages
- Both tested and functional

### Git Status
Files added but not committed:
- config/tmux/, config/wezterm/
- profiles/*.nix
- modules/*.nix updates
- starship.toml
- Example flakes

### User Decision Point
User is considering:
1. **Keep home-manager** with profiles (current working setup)
2. **Switch to devShells** approach (simpler, more modern)
3. **Hybrid**: Packages for dotfiles + something else for tools

**Recommendation Given:** Try devShells approach (flake-devshell.nix) as it's cleaner and more aligned with modern Nix workflows.

## Next Steps (User's Choice)

### Option A: Finalize Home-Manager Setup
```bash
git commit -am "feat: migrate dotfiles to home-manager with profiles"
home-manager switch --flake .#darwin-development
```

### Option B: Switch to devShells
```bash
mv flake.nix flake-homemanager-backup.nix
mv flake-devshell.nix flake.nix
nix develop  # Enter dev environment
```

### Option C: Hybrid Approach
- Create packages for dotfiles (static, shareable)
- Use devShells for development tools (per-project)
- Optional: minimal home-manager for system packages

## Repository Structure

```
home-manager/
├── config/
│   ├── tmux/           # Tmux configs + TPM
│   └── wezterm/        # WezTerm Lua config
├── profiles/
│   ├── base.nix
│   ├── minimal.nix
│   ├── development.nix
│   ├── work.nix
│   └── personal.nix
├── modules/
│   ├── shell.nix       # Fish + plugins
│   ├── starship.nix
│   ├── git.nix
│   ├── editors.nix
│   ├── multiplexers.nix
│   ├── terminals.nix
│   └── tools.nix
├── starship.toml       # Custom prompt
├── flake.nix          # Main config with profiles
├── flake-clean.nix    # Example: packages approach
├── flake-devshell.nix # Example: devShells approach
└── darwin.nix         # macOS system config
```

## Important Context for Future Sessions

1. **User's dotfiles location**: `/Users/ray/dotfiles` (original chezmoi setup, still exists)
2. **Work repo**: `/Users/ray/repos/home-manager` (new Nix setup)
3. **Platform**: macOS (aarch64-darwin)
4. **Preference**: Wants simplicity over power features
5. **Fish plugins note**: Some have hash mismatches, omitted for now
6. **Approach undecided**: User hasn't committed to home-manager vs devShells yet

## Commands Reference

### Home-Manager Profile Switching
```bash
home-manager switch --flake .#darwin-minimal
home-manager switch --flake .#darwin-development
home-manager switch --flake .#darwin-work
home-manager generations  # List all generations
home-manager switch --rollback  # Rollback
```

### devShells (if switched)
```bash
nix develop              # Default dev environment
nix develop .#minimal    # Minimal shell
nix develop .#work       # Work environment
```

### Building Specific Profiles
```bash
nix build .#homeConfigurations.darwin-minimal.activationPackage
nix build .#homeConfigurations.darwin-development.activationPackage
```
