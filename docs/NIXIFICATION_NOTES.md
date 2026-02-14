# Nixification Notes

## 2026-02-14: Tmux & Mise Nixification

### Summary
Migrated from raw config files to pure Nix home-manager modules for cleaner, more maintainable configuration.

### Changes Made

#### 1. Mise Shell Integration ✅
- **Status**: Already configured properly
- **Location**: `modules/shell.nix:205-207`
- **Integration**: Automatic fish shell activation via `mise activate fish | source`
- **Usage**: Just install mise globally and it auto-activates

#### 2. Tmux Nixification ✅
**Replaced**: Raw config files (tmux.conf, tmux.conf.plugins) with TPM
**With**: `programs.tmux` home-manager module with Nix-managed plugins

**Benefits**:
- ✨ No TPM (Tmux Plugin Manager) needed - plugins managed by Nix
- 🔒 Reproducible - same config on any machine
- 🧹 Cleaner - all configuration in one Nix file
- 🚀 Faster - plugins pre-built by Nix cache

**Configuration**: `modules/multiplexers.nix`

### Tmux Features (Nixified)

#### Core Settings
- **Prefix**: `Ctrl-s` (more ergonomic than Ctrl-b)
- **Mouse**: Enabled
- **Vi Mode**: Enabled for copy mode
- **Base Index**: Starts at 1 (more intuitive)
- **Escape Time**: 10ms (fast for Neovim)
- **History**: 50,000 lines

#### Plugins (Nix-managed)
| Plugin | Purpose |
|--------|---------|
| **sensible** | Sane default settings |
| **resurrect** | Save/restore sessions |
| **continuum** | Auto-save sessions every 15min |
| **pain-control** | Better pane navigation |
| **vim-tmux-navigator** | Seamless vim ↔ tmux navigation |
| **yank** | System clipboard integration |
| **cpu** | CPU usage in status bar |
| **battery** | Battery status with icons |
| **catppuccin** | Beautiful Mocha theme |

#### Key Bindings
| Key | Action |
|-----|--------|
| `Ctrl-s` | Prefix |
| `Ctrl-s r` | Reload config |
| `Ctrl-s a` | Send literal Ctrl-s |
| `Ctrl-s Enter` | Lock mode (disable all keys) |
| `Ctrl-g` | Unlock from lock mode |
| `Ctrl-s v` | Copy mode with vi keys |

#### Status Bar (Top)
- 🖥️ CPU usage (color-coded: green/yellow/red)
- 🔋 Battery percentage with icon
- 📦 Session name
- 👤 User@host
- 🕐 Date and time

### File Structure Changes

**Removed** (old approach):
```
config/tmux/
├── tmux.conf          # ❌ Deleted (raw config)
├── tmux.conf.plugins  # ❌ Deleted (TPM plugins)
├── tmux.conf.nvim     # ❌ Deleted (nvim integration)
└── scripts/           # ⚠️ Kept for now (custom scripts)
```

**Added** (new approach):
```
modules/multiplexers.nix  # ✅ Pure Nix tmux config
```

### Migration Path

**Before** (TPM approach):
1. Install tmux
2. Clone TPM
3. Symlink config files
4. Run `Ctrl-s I` to install plugins
5. Plugins managed by TPM

**After** (Nix approach):
1. Enable `programs.tmux` in home-manager
2. Define plugins in Nix
3. Run `home-manager switch`
4. Everything just works!

### Next Steps

If you want to customize further:

**Add more plugins**:
```nix
# In modules/multiplexers.nix, add to plugins list:
{
  plugin = pkgs.tmuxPlugins.fzf-tmux-url;
  extraConfig = "# Extract URLs with fzf";
}
```

**Change theme**:
```nix
# Replace catppuccin with another theme:
{
  plugin = pkgs.tmuxPlugins.nord;
  extraConfig = "# Nord theme";
}
```

**Modify keybindings**:
```nix
# In extraConfig section:
extraConfig = ''
  # Your custom key here
  bind-key C-a last-window
'';
```

### Testing

```bash
# Build the configuration
nix build .#homeConfigurations.darwin.activationPackage

# Apply it
./result/activate

# Or use home-manager if installed
home-manager switch --flake .#darwin
```

### Rollback

If anything breaks:
```bash
# List generations
home-manager generations

# Rollback to previous
home-manager rollback
```

### Notes

- The old `config/tmux/` directory can be safely removed (except scripts/ if you use them)
- TPM is no longer needed - uninstall with `rm -rf ~/.config/tmux/plugins/tpm`
- All plugins are now in `/nix/store` and managed by Nix
- Configuration is now version-controlled and reproducible
