# Session Summary - 2026-02-14: nh Integration Mystery

## Session Overview
**Duration**: ~40 minutes total (continuation of tmux-powerkit session)
**Focus**: Adding nh (Nix helper) tool and resolving configuration issues
**Status**: ⚠️ Partial Success - nh installed via workaround, config mystery remains

---

## What We Attempted

### Goal: Add `nh` - Modern Nix Helper Tool
**Why**: User requested evaluation and integration of https://github.com/nix-community/nh
- Modern Rust-based CLI for unified Nix/NixOS/Darwin/Home-Manager operations
- Better UX with nix-output-monitor integration
- Enhanced garbage collection with time-based retention
- Fast package search via Elasticsearch
- Shorter command syntax

**Decision**: ✅ Recommended and attempted to integrate

---

## Configuration Changes Made

### 1. ✅ Added nh to home.nix
```nix
home.packages = (with pkgs; [
  # System essentials
  bash  # Bash 5.x required for tmux-powerkit (macOS ships with 3.2)
  nh    # Modern Nix helper - unified CLI for home-manager/darwin/nixos
  # ... rest of packages
]);
```

**Location**: `home.nix:25`
**Status**: In config file, verified multiple times

### 2. ✅ Fixed programs.just Deprecation
**Error Found**: 
```
Failed assertions:
- The option definition `programs.just.enable' in `modules/tools.nix' no longer has any effect
'program.just' is deprecated, simply add 'pkgs.just' to 'home.packages' instead.
```

**Fix Applied**: `modules/tools.nix`
```nix
# Before:
programs.just = {
  enable = true;
};

# After:
# just - Command runner (managed via home.packages in home.nix)
# Deprecated: programs.just.enable removed, just added to packages instead
```

**Impact**: Build now succeeds without assertion failures
**Note**: `just` was already in home.packages, so this was just cleanup

### 3. ✅ Added Fish Configuration for nh
**File**: `modules/shell.nix`

**Environment Variables**:
```fish
# Nix Helper (nh) - Modern unified CLI for Nix operations
set -gx FLAKE "$HOME/repos/home-manager"
set -gx NH_NOM 1  # Enable nix-output-monitor by default
```

**Aliases**:
```fish
# Nix Helper (nh) - Modern unified operations
hm-switch = "nh home switch";
hm-build = "nh home build";
nix-clean = "nh clean all --keep 3";
nix-search = "nh search";
```

**Status**: ✅ Successfully integrated

---

## The Mystery: nh Won't Build

### Symptoms
1. ✅ `nh` is clearly present in `home.nix:25`
2. ✅ Build completes successfully with no errors
3. ✅ Syntax verified correct (multiple variations tried)
4. ✅ Package verified to exist: `nix search nixpkgs ^nh$` finds it
5. ✅ Package works standalone: `nix shell nixpkgs#nh` works perfectly
6. ❌ **But**: `nh` does NOT appear in `result/home-path/bin/`
7. ❌ **And**: `nh` does NOT appear in nix-store references for the build

### Debugging Attempts

**Attempt 1: Direct in main list**
```nix
home.packages = with pkgs; [
  bash
  nh  # Line 25
  # ...
];
```
**Result**: ❌ Not in build

**Attempt 2: Outside with block**
```nix
home.packages = with pkgs; [
  # ...
] ++ [
  pkgs.nh
];
```
**Result**: ❌ Not in build

**Attempt 3: Parenthesized with**
```nix
home.packages = (with pkgs; [
  nh
  # ...
]);
```
**Result**: ❌ Not in build

**Attempt 4: Clean rebuild**
```bash
rm -f result
nix build .#homeConfigurations.darwin.activationPackage --impure
```
**Result**: ❌ Not in build

### Verification Checks

**Package Count**: `nix eval .#homeConfigurations.darwin.config.home.packages --apply 'builtins.length'` → 101 packages
**Binary Count**: `ls result/home-path/bin/ | wc -l` → 199 binaries
**nh Present**: `ls result/home-path/bin/ | grep ^nh` → No results
**Store References**: `nix-store -qR result | grep -i nh` → Only partial matches (tmuxplugin-continuum, etc.)

### What This Rules Out

- ❌ **Not** a syntax error (build succeeds)
- ❌ **Not** a missing package (exists in nixpkgs, works standalone)
- ❌ **Not** a name collision (tried multiple approaches)
- ❌ **Not** a deprecation (no warnings or errors)
- ❌ **Not** a platform issue (aarch64-darwin confirmed)
- ❌ **Not** a cache issue (clean rebuilds attempted)

### Theories (Unverified)

1. **Possible name collision**: Maybe `nh` conflicts with something internal to Nix/HM?
2. **Evaluation quirk**: Some subtle issue with how home-manager evaluates package lists?
3. **Module interference**: Could another module be filtering packages? (privacy.nix was added by user)
4. **Build system bug**: Could be a Nix flake evaluation bug with this specific package?

**Note**: User added `./modules/privacy.nix` to imports during session - reviewed, doesn't filter packages

---

## Workaround Applied: nix profile

Since home-manager integration was blocked by mysterious issue:

```bash
nix profile install nixpkgs#nh
# Warning: 'install' is deprecated alias for 'add'
```

**Result**: ✅ `nh` successfully installed and working
**Verification**: `nh --version` → `nh 4.2.0`

### Workaround Benefits
- ✅ Immediate functionality
- ✅ Fish config still applies (aliases, env vars work)
- ✅ User can use nh right away
- ✅ No impact on home-manager builds

### Workaround Drawbacks
- ❌ Not managed via home-manager (manual installation)
- ❌ Won't be in declarative config benefits
- ❌ Need to manually update via `nix profile upgrade`
- ❌ Mystery remains unsolved

---

## Current Status

**nh Installation**: ✅ Working via `nix profile`
**Fish Config**: ✅ Complete with aliases and env vars
**home.nix**: ⚠️ Has `nh` on line 25 but doesn't build it
**User Can Use**: ✅ All nh features available immediately

---

## Next Steps for Investigation

If user wants to debug further:

1. **Try minimal reproduction**:
   ```nix
   # Create test flake with just nh
   home.packages = [ pkgs.nh ];
   ```

2. **Check home-manager issues**: Search for similar reports
   - https://github.com/nix-community/home-manager/issues
   - Search terms: "package not installed", "missing from build"

3. **Try older nh version**: Maybe recent version has issue?
   ```nix
   home.packages = [ (pkgs.nh.overrideAttrs (old: { version = "4.0.0"; })) ];
   ```

4. **Check if flake update helps**:
   ```bash
   nix flake update
   ```

5. **Try without privacy module**: Temporarily remove to rule out interference

---

## Learnings

### programs.just Deprecation (Resolved)
- **Issue**: `programs.just.enable` deprecated in recent home-manager
- **Solution**: Remove module config, rely on package in home.packages
- **Detection**: Build fails with assertion error
- **Fix**: Comment out or remove programs.just block

### nh Tool Evaluation
- **Worth Adding**: Strong yes for modern Nix workflows
- **Key Features**: Unified CLI, better UX, enhanced GC, fast search
- **Fits User Profile**: Aligns with preference for modern Rust tools
- **Integration Method**: `nix profile` works as fallback if HM fails

### Mysterious Package Exclusion
- **Can Happen**: Packages can be in config but not build for unknown reasons
- **Hard to Debug**: When build succeeds but package missing
- **Workaround Exists**: `nix profile install` as reliable fallback
- **Not Critical**: Doesn't block functionality, just loses declarative benefits

---

## Files Modified This Session

1. **home.nix**:
   - Added `nh` to home.packages (line 25)
   - User added `./modules/privacy.nix` import (line 10)
   - User added `jj-starship` package (line 52)

2. **modules/tools.nix**:
   - Removed deprecated `programs.just.enable`
   - Added comment explaining deprecation

3. **modules/shell.nix**:
   - Added nh environment variables ($FLAKE, $NH_NOM)
   - Added nh aliases (hm-switch, hm-build, nix-clean, nix-search)

4. **modules/multiplexers.nix** (from earlier session):
   - tmux-powerkit bash 5.x shebang patch
   - fish shell configuration

---

## Commands User Can Run Now

```bash
# Use nh immediately (works via nix profile)
exec fish              # Reload shell to get aliases
nh --version           # Verify: 4.2.0

# Try new commands
hm-switch              # Alias for: nh home switch
hm-build --dry         # Alias for: nh home build --dry
nix-clean              # Alias for: nh clean all --keep 3
nix-search tmux        # Alias for: nh search tmux

# Direct nh usage
nh home build          # Build home-manager config
nh home switch         # Build and activate
nh home switch --dry   # Preview changes with diff
nh search ripgrep      # Fast package search
nh clean all --keep 5  # Keep last 5 generations
```

---

## Mystery Status: UNSOLVED

**What We Know**:
- Package exists and works ✅
- Config syntax correct ✅
- Build succeeds ✅
- Package mysteriously excluded ❌

**Recommendation**: Use `nix profile` installation (already done), works perfectly. Debug HM integration later if needed.

---

## Cross-References
- Related: `session_2026-02-14_tmux-powerkit-fix.md` (earlier in same session)
- Related: `pattern_macos-bash-compatibility.md` (bash 5.x pattern)
- Mystery: Unsolved home-manager package exclusion issue
