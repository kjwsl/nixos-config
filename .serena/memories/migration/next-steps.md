# Next Steps: Migration Continuation

## Immediate Actions

### 1. Activate Configuration ⚠️
```bash
cd ~/repos/home-manager
home-manager switch --flake .#ray-darwin
```
This will:
- Create actual symlinks from `~/.config/` to `~/repos/home-manager/dotfiles/`
- Activate all shell configurations
- Apply git/jujutsu settings
- Enable all migrated programs

### 2. Copy Existing Configs to Dotfiles
```bash
# Example: Copy existing nvim config
cp -r ~/.config/nvim ~/repos/home-manager/dotfiles/nvim

# Do this for: wezterm, ghostty, alacritty, kitty, tmux, zellij, etc.
```

### 3. Commit the Changes
```bash
git add -A
git commit -m "feat: migrate to modular Nix structure

- Create home/programs/shells.nix (fish, nushell, bash, zsh)
- Create home/programs/git.nix (git, jujutsu, lazygit, gh)
- Create home/dotfiles.nix (mutable symlinks)
- Update to modern home-manager APIs
- Fix Nix string escaping for bash aliases
- Separate delta configuration from git module"
```

## Phase 4: Additional Migrations

### CLI Tools to Migrate
Create `home/programs/cli-tools.nix`:
- **btop** - System monitor
- **yazi** - File manager
- **starship** - Prompt (currently disabled in home.nix)
- **fastfetch** - System info

### Pattern
```nix
# home/programs/cli-tools.nix
{ config, pkgs, ... }:
{
  programs.btop = {
    enable = true;
    settings = { ... };
  };
  
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    # ...
  };
}
```

## Phase 5: Chezmoi Cleanup

### Decision Point
1. **Full Elimination**: Remove chezmoi entirely
   - Migrate secrets to sops-nix
   - Move all remaining configs to Nix
   
2. **Secrets Only**: Keep chezmoi for secrets only
   - Remove duplicate configs from chezmoi
   - Use chezmoi only for `.secrets`, API keys, etc.

### Files to Remove from Chezmoi
- Binary files (VST plugins, fonts) - handled by Nix
- Wrong-platform configs (Windows configs on macOS, Linux DE configs)
- Configs now in Nix (shells, git, etc.)

### Commands
```bash
# Audit what's left
chezmoi managed

# Remove specific files
chezmoi forget <file>

# Or start fresh
rm -rf ~/.local/share/chezmoi
```

## Testing Checklist

After activation:
- [ ] Fish shell loads with correct theme and key bindings
- [ ] Git commands work with conventional commits aliases
- [ ] Delta pager works for git diff
- [ ] Jujutsu (jj) commands work
- [ ] Symlinks point to correct dotfiles directories
- [ ] Can edit nvim config without rebuild
- [ ] Session variables (EDITOR, PATH) are correct

## Validation
```bash
# Check symlinks
ls -la ~/.config/nvim ~/.config/wezterm

# Test shell
fish -c 'echo $EDITOR'

# Test git
git feat test message
git lg

# Test jujutsu
jj lg
```
