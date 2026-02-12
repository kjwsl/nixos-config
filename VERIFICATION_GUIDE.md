# Fish Plugin Migration Verification Guide

This guide documents the manual verification steps for the fish shell plugin migration from fisher to Home-Manager.

## Overview

All 12 fish plugins have been migrated from fisher-managed to Home-Manager's native plugin management in `fish.nix`. This guide helps verify that all functionality has been preserved.

## Prerequisites

Before verification, apply the configuration:

```bash
# From the main home-manager repository
darwin-rebuild switch --flake .
```

After the rebuild completes, open a **new fish shell** for testing.

## Verification Checklist

### 1. Shell Startup Verification

**What to check:**
- [ ] No fisher-related messages appear
- [ ] No error messages during shell initialization
- [ ] Prompt appears correctly with Catppuccin Mocha theme
- [ ] No warnings about missing plugins

**How to verify:**
```bash
# Open a new fish shell and observe the startup
fish
```

Expected: Clean startup with themed prompt, no errors.

---

### 2. Plugin Functionality Tests

#### 2.1 Bass (Bash Script Compatibility)

**Purpose:** Allows running bash scripts in fish shell

**Test:**
```bash
bass echo "Hello from bass"
bass export TEST_VAR=123
echo $TEST_VAR
```

**Expected:** Should output "Hello from bass" and TEST_VAR should be set to 123.

---

#### 2.2 FZF Integration (fzf.fish)

**Purpose:** Fuzzy finding for history, files, directories, and more

**Test 1 - History Search:**
```bash
# Press Ctrl+R
# Should open fzf history search interface
```

**Test 2 - File Search:**
```bash
# Press Ctrl+Alt+F (or configured key)
# Should open fzf file search
```

**Expected:** Interactive fzf interfaces appear and are functional.

---

#### 2.3 Zoxide (Smart Directory Navigation)

**Purpose:** Intelligent directory jumping based on frecency

**Test:**
```bash
# First, visit some directories to build up the database
cd ~/Downloads
cd ~/Documents
cd ~

# Now test zoxide
z Down  # Should jump to ~/Downloads
z Doc   # Should jump to ~/Documents
```

**Expected:** Zoxide navigates to frequently used directories with partial matches.

---

#### 2.4 Done (Command Completion Notifications)

**Purpose:** Shows notifications when long-running commands complete

**Test:**
```bash
sleep 11  # Default threshold is 10 seconds
```

**Expected:** After 11 seconds, you should see a notification that the command completed.

---

#### 2.5 Catppuccin Theme

**Purpose:** Provides the Catppuccin Mocha color scheme

**Test:**
```bash
fish_config theme show
```

**Expected:** Should show "Catppuccin Mocha" as the active theme. The prompt should display in Catppuccin colors (pastel/muted tones).

---

#### 2.6 Git Plugin (plugin-git)

**Purpose:** Provides git-related utilities and functions

**Test:**
```bash
# Check git functions are available
functions | grep git
```

**Expected:** Should show multiple git-related functions loaded by the plugin.

---

#### 2.7 Puffer Fish (Text Expansion)

**Purpose:** Expands text shortcuts

**Test:**
```bash
# Type !! and press space
# Should expand to the previous command
```

**Expected:** `!!` expands to your last command when followed by space.

---

#### 2.8 Sponge (Failed Command Removal)

**Purpose:** Removes failed commands from history

**Test:**
```bash
false  # This command fails
history | tail -n 5
```

**Expected:** The `false` command should not appear in history.

---

#### 2.9 Abbreviation Tips

**Purpose:** Shows hints when you type an abbreviation

**Test:**
```bash
# If you have git abbreviations, type them
g  # Should show a tip if 'g' is an abbreviation
```

**Expected:** Tips appear when typing known abbreviations.

---

#### 2.10 Nix Environment (nix-env.fish)

**Purpose:** Proper nix environment integration

**Test:**
```bash
echo $NIX_PROFILES
nix --version
```

**Expected:** Nix environment variables are set, nix command is available.

---

#### 2.11 Replay

**Purpose:** Record and replay command sequences

**Test:**
```bash
functions | grep replay
```

**Expected:** Replay functions should be available.

---

#### 2.12 Spark

**Purpose:** Generate sparkline charts in the terminal

**Test:**
```bash
echo 1 2 3 4 5 | spark
```

**Expected:** Should display a small sparkline chart.

---

### 3. Aliases Verification

**Test all configured aliases:**

```bash
# Tree alias
tree --version  # Should show tree-rs or similar

# Neovim alias
v --version  # Should show neovim version

# Git alias
g status  # Should run 'git status'

# Zoxide alias
zo  # Should be aliased to 'zi' (zoxide interactive)
```

**Expected:** All aliases work as configured.

---

### 4. Functions Verification

**Test all custom functions:**

```bash
# List all functions
functions | grep -E "vf|zf|envsource|pi|smartdd"

# Test vf (fuzzy find and edit with nvim)
vf  # Should open fzf to select a file, then edit in nvim

# Test zf (fuzzy find and cd)
zf  # Should open fzf to select a directory, then cd to it
```

**Expected:** All custom functions are available and work correctly.

---

### 5. Key Bindings Verification

**Test configured key bindings:**

```bash
# Press \cf (backslash + c + f)
# Should trigger the 'zf' function (fuzzy directory search)
```

**Expected:** Custom key bindings work as configured.

---

### 6. No Fisher References

**Verify fisher is not installed or running:**

```bash
type -q fisher
echo $status  # Should output: 1

# Check for fisher in PATH
which fisher  # Should output: fisher not found
```

**Expected:** Fisher command is not available (status 1 = not found).

---

## Summary Checklist

- [ ] Shell starts without errors
- [ ] All 12 plugins load correctly
- [ ] Bass works for bash compatibility
- [ ] FZF integration works (Ctrl+R for history)
- [ ] Zoxide directory jumping works
- [ ] Done notifications work for long commands
- [ ] Catppuccin Mocha theme is active
- [ ] Git plugin functions are available
- [ ] Puffer-fish text expansion works
- [ ] Sponge removes failed commands
- [ ] Abbreviation tips appear
- [ ] Nix environment is properly set
- [ ] Replay functions available
- [ ] Spark can generate charts
- [ ] All aliases work (v, g, tree, zo)
- [ ] All functions work (vf, zf, envsource, pi, smartdd)
- [ ] Key bindings work (\cf for zf)
- [ ] No fisher references or auto-install messages

## Troubleshooting

### If plugins don't load:

1. Check fish.nix syntax:
   ```bash
   nix flake check
   ```

2. Check for build errors:
   ```bash
   darwin-rebuild switch --flake . --show-trace
   ```

3. Verify fish.nix is imported in flake.nix

### If specific plugin doesn't work:

1. Check if plugin is listed:
   ```bash
   fish -c 'echo $fish_plugins'
   ```

2. Check plugin source paths:
   ```bash
   ls -la ~/.nix-profile/share/fish/vendor_*
   ```

3. Check for plugin-specific errors in fish:
   ```bash
   fish --debug
   ```

## Success Criteria

All items in the Summary Checklist should be checked (✓). If any item fails, refer to the Troubleshooting section or review the fish.nix configuration.

## Migration Completion

Once all verifications pass:

1. The migration is complete
2. Fisher is no longer needed and can be removed
3. All plugins are now managed by Home-Manager
4. Future plugin updates will be handled via nix flake update
