# Session Summary - 2026-02-14: tmux-powerkit Bash Fix

## Session Overview
**Duration**: ~20 minutes  
**Focus**: Fixing tmux-powerkit plugin failure and shell configuration issues  
**Status**: ✅ Complete - Ready for user verification

---

## Problems Diagnosed & Resolved

### 1. ✅ tmux-powerkit Plugin Failure
**Error**: `tmux-powerkit.tmux returned 1`

**Root Cause**:
- tmux-powerkit requires **Bash 5.1+** for modern features:
  - `declare -g` (global variable declaration) - Bash 4.2+
  - `${var^^}` (uppercase parameter expansion) - Bash 4.0+
  - `assoc_expand_once` (associative array optimization) - Bash 5.1+
- macOS ships with **Bash 3.2.57** due to GPLv2 licensing restrictions
- Plugin shebang used `/usr/bin/env bash` → system bash 3.2

**Solution**:
```nix
# modules/multiplexers.nix
tmux-powerkit = pkgs.tmuxPlugins.mkTmuxPlugin {
  # ... plugin config ...
  
  # Patch shebang to use Nix-provided bash 5.x
  postInstall = ''
    substituteInPlace $target/tmux-powerkit.tmux \
      --replace '#!/usr/bin/env bash' '#!${pkgs.bash}/bin/bash'
  '';
  
  nativeBuildInputs = [ pkgs.bash ];
};
```

**Result**: Plugin now uses `/nix/store/.../bash-5.3p9/bin/bash`

---

### 2. ✅ tmux Opens zsh Instead of fish (Issue 1)
**Symptom**: New tmux panes opened with zsh, not fish

**Root Cause**:
- `programs.tmux.shell` was not configured
- tmux defaulted to system shell `/bin/zsh`

**Solution**:
```nix
programs.tmux = {
  enable = true;
  shell = "${pkgs.fish}/bin/fish";  # Explicitly set fish
  # ...
};
```

---

### 3. ✅ tmux Opens zsh Instead of fish (Issue 2)
**Symptom**: Title said "fish" but shell was still zsh

**Root Cause**:
- home-manager automatically adds `reattach-to-user-namespace` on macOS for clipboard
- Auto-generated `default-command` hardcoded `/bin/zsh`:
  ```
  default-command "reattach-to-user-namespace -l /bin/zsh"
  ```
- `default-command` overrides `default-shell` in tmux

**Solution**:
```nix
extraConfig = ''
  # Override HM's auto-generated default-command to use fish
  set -g default-command "${pkgs.fish}/bin/fish"
  # ...
'';
```

---

## Files Modified

### `modules/multiplexers.nix`
1. Added tmux-powerkit bash 5.x shebang patch
2. Added `shell = "${pkgs.fish}/bin/fish";` to programs.tmux
3. Added `default-command` override in extraConfig

### `home.nix`
1. Added `bash` to home.packages (for tmux-powerkit runtime)

---

## Key Technical Learnings

### macOS Bash Constraints
- macOS stuck on Bash 3.2 due to GPL licensing (GPLv2 vs GPLv3)
- Modern bash scripts require Nix-provided bash for compatibility
- Always patch shebangs when using bash-dependent plugins

### tmux Shell Configuration Hierarchy
1. `default-command` (highest priority) - explicit command to run
2. `default-shell` - shell to use when no command specified
3. System default shell (lowest priority) - fallback

**Lesson**: On macOS with home-manager, must override **both**:
- Set `programs.tmux.shell` for HM module
- Set `default-command` in extraConfig to override auto-generated value

### home-manager macOS Behavior
- Automatically adds `reattach-to-user-namespace` for clipboard support
- Hardcodes shell to `/bin/zsh` in default-command
- Requires explicit override to use different shell

---

## Build & Activation Status

**Build Command**: `nix build .#homeConfigurations.darwin.activationPackage --impure`  
**Build Status**: ✅ Successful  
**Activation Status**: ✅ Complete  

**Next User Action**: Reload tmux config without killing server:
```bash
tmux source-file ~/.config/tmux/tmux.conf
```

---

## Verification Steps (Pending User)

1. ✅ Build successful
2. ✅ Activation complete
3. ⏳ User reloads tmux config
4. ⏳ User creates new pane/window
5. ⏳ Verify fish shell loads (not zsh)
6. ⏳ Verify tmux-powerkit status bar appears
7. ⏳ Verify powerkit plugins work (cpu, battery, time, hostname)

---

## Pattern: Fixing Shell Plugins on macOS

**When a plugin requires modern bash:**

1. **Diagnose**: Check plugin shebang and bash version requirements
2. **Verify**: Test on Nix bash (`/nix/store/.../bash-5.x/bin/bash`)
3. **Patch**: Use `postInstall` with `substituteInPlace` to fix shebang
4. **Ensure**: Add bash to `nativeBuildInputs` or `home.packages`

**Template**:
```nix
myPlugin = pkgs.tmuxPlugins.mkTmuxPlugin {
  # ... config ...
  postInstall = ''
    substituteInPlace $target/script.sh \
      --replace '#!/usr/bin/env bash' '#!${pkgs.bash}/bin/bash'
  '';
  nativeBuildInputs = [ pkgs.bash ];
};
```

---

## Cross-References
- Related: `session_2026-02-14.md` (tmux-powerkit integration)
- Related: `home-manager-migration-session.md` (overall migration)
- Pattern: Custom plugin integration with shell requirements
