# Nix Syntax Patterns & Learnings

## String Escaping in Nix

### Problem: Bash Variables in Nix Strings
When embedding bash code with `${var}` syntax in Nix, the `${` triggers Nix string interpolation.

**Wrong:**
```nix
alias = "!a() { echo \"${_message}\"; }; a";
# Error: Nix tries to interpolate ${_message}
```

**Correct - Multi-line String Escape:**
```nix
alias = ''!a() { echo "''${_message}"; }; a'';
# The ''${ escapes to literal ${
```

### Multi-line Strings (`''..''`)
- `$` is literal by default
- `''${` produces literal `${` (for bash variables)
- `${` still triggers Nix interpolation
- Cleaner for bash functions with many variables

## Home-Manager API Evolution

### Deprecated → Modern
```nix
# OLD (deprecated)
programs.git.userName = "ray";
programs.git.userEmail = "email@example.com";
programs.git.extraConfig = { ... };
programs.git.aliases = { ... };
programs.git.delta.enable = true;

# NEW (current)
programs.git.settings = {
  user.name = "ray";
  user.email = "email@example.com";
  alias = { ... };
  # other settings...
};

# Delta is separate
programs.delta = {
  enable = true;
  enableGitIntegration = true;
  options = { ... };
};
```

### Zsh API Update
```nix
# OLD
programs.zsh.initExtra = ''...'';

# NEW
programs.zsh.initContent = ''...'';
```

## Module Conflicts & Resolution

### Automatic Integration
Some modules auto-configure related tools:
- `programs.gh.enable = true` → auto-sets git credential helper
- `programs.delta.enable = true` → auto-sets `core.pager` and `interactive.diffFilter`

**Solution:** Remove manual settings that conflict with module defaults.

## mkOutOfStoreSymlink Pattern

### Purpose
Allow editing configs without `home-manager switch` while keeping them version-controlled.

### Usage
```nix
let
  dotfilesDir = "${config.home.homeDirectory}/repos/home-manager/dotfiles";
in {
  xdg.configFile."nvim".source = 
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/nvim";
}
```

### Requirements
- Target directory must exist: `mkdir -p ~/repos/home-manager/dotfiles/nvim`
- Use absolute paths (no `~/` - use `${config.home.homeDirectory}`)
- Files in target are mutable (edit freely, changes persist)
- Still version-controlled via git

## Git Flake Requirements

### Critical Rule
**All referenced files must be tracked by Git.**

```bash
# Before building
git add file.nix

# Otherwise: "Path 'file.nix' is not tracked by Git"
```

### Uncommitted Changes
Flakes allow uncommitted changes but warn:
```
warning: Git tree '/path' has uncommitted changes
```
Build proceeds, but changes are "dirty" in flake.lock.
