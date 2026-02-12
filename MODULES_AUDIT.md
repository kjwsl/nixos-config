# Home-Manager Modules Audit

**Date:** 2026-02-13
**Purpose:** Document which packages can be converted from `home.packages` to native Home-Manager modules

---

## 🎯 Implementation Results

**Implementation Date:** 2026-02-13
**Status:** ✅ Complete

### Final Statistics
- **Total Packages:** 72 (excluding 3 commented out)
- **Successfully Converted:** 17 tools → Native HM modules
- **Remaining as Packages:** 55 tools

### Modules Created
1. **`modules/shell.nix`** - Shell environment (4 tools: fish, zoxide, fzf, atuin)
2. **`modules/starship.nix`** - Cross-shell prompt (1 tool: starship)
3. **`modules/git.nix`** - Git & version control (3 tools: git, delta, lazygit)
4. **`modules/editors.nix`** - Text editors (1 tool: neovim)
5. **`modules/multiplexers.nix`** - Terminal multiplexers (2 tools: tmux, zellij)
6. **`modules/tools.nix`** - CLI utilities (6 tools: bat, eza, yazi, btop, broot, nushell)

### Benefits Achieved
✅ **Type Safety** - Nix validates all configurations at build time
✅ **Integration** - Tools automatically integrate with fish shell
✅ **Consistency** - Uniform configuration style across all modules
✅ **Documentation** - Self-documenting with Home-Manager option descriptions
✅ **Maintainability** - Easier to update and modify configurations

### Implementation Decisions
- **Prioritized high-value conversions** - Focused on frequently-used tools with rich configuration options
- **Skipped low-priority tools** - mcfly, tealdeer, jujutsu, ripgrep, skim, bottom remain as packages (limited benefit from native modules)
- **Avoided duplicates** - Kept eza (not lsd), btop configured natively (bottom remains as package for choice)
- **Build verification** - Manual verification required: `darwin-rebuild build --flake .#ray`

---

## Original Audit Summary

- **Total Packages:** 72 (excluding 3 commented out)
- **Identified for Conversion:** 22 tools
- **Actually Converted:** 17 tools
- **Remaining as Packages:** 55 tools

## Priority 1: Shell & Development Environment (9 tools)

These are high-usage tools that benefit most from native module configuration.

| Tool | Package | HM Module | Priority | Status | Notes |
|------|---------|-----------|----------|--------|-------|
| fish | ✅ | `programs.fish` | HIGH | ✅ **Converted** | Shell with native config support → `modules/shell.nix` |
| starship | ✅ | `programs.starship` | HIGH | ✅ **Converted** | Prompt with TOML config support → `modules/starship.nix` |
| zoxide | ✅ | `programs.zoxide` | HIGH | ✅ **Converted** | Smart directory jumper → `modules/shell.nix` |
| fzf | ✅ | `programs.fzf` | HIGH | ✅ **Converted** | Fuzzy finder with shell integration → `modules/shell.nix` |
| atuin | ✅ | `programs.atuin` | HIGH | ✅ **Converted** | Shell history with sync support → `modules/shell.nix` |
| nushell | ✅ | `programs.nushell` | MEDIUM | ✅ **Converted** | Alternative shell → `modules/tools.nix` |
| mcfly | ✅ | `programs.mcfly` | MEDIUM | ⏭️ **Skipped** | Neural shell history - kept as package (limited config benefit) |
| broot | ✅ | `programs.broot` | MEDIUM | ✅ **Converted** | Directory navigator → `modules/tools.nix` |
| tealdeer | ✅ | `programs.tealdeer` | MEDIUM | ⏭️ **Skipped** | tldr client - kept as package (minimal config needed) |

## Priority 2: Git & Version Control (3 tools)

Git-related tools with rich configuration options.

| Tool | Package | HM Module | Priority | Status | Notes |
|------|---------|-----------|----------|--------|-------|
| git | ✅ | `programs.git` | HIGH | ✅ **Converted** | VCS with extensive config, aliases, delta integration → `modules/git.nix` |
| lazygit | ✅ | `programs.lazygit` | HIGH | ✅ **Converted** | TUI git client with YAML config → `modules/git.nix` |
| jujutsu | ✅ | `programs.jujutsu` | MEDIUM | ⏭️ **Skipped** | Modern VCS - kept as package (user may prefer default config) |

## Priority 3: Editors (1 tool)

| Tool | Package | HM Module | Priority | Status | Notes |
|------|---------|-----------|----------|--------|-------|
| neovim | ✅ | `programs.neovim` | HIGH | ✅ **Converted** | Editor with plugin management → `modules/editors.nix` |

## Priority 4: Terminal Multiplexers (2 tools)

| Tool | Package | HM Module | Priority | Status | Notes |
|------|---------|-----------|----------|--------|-------|
| tmux | ✅ | `programs.tmux` | HIGH | ✅ **Converted** | Terminal multiplexer with native config → `modules/multiplexers.nix` |
| zellij | ✅ | `programs.zellij` | HIGH | ✅ **Converted** | Modern terminal multiplexer → `modules/multiplexers.nix` |

## Priority 5: CLI Utilities (7 tools)

Common CLI tools with configuration support.

| Tool | Package | HM Module | Priority | Status | Notes |
|------|---------|-----------|----------|--------|-------|
| bat | ✅ | `programs.bat` | HIGH | ✅ **Converted** | Cat replacement with syntax highlighting → `modules/tools.nix` |
| eza | ✅ | `programs.eza` | HIGH | ✅ **Converted** | Ls replacement (formerly exa) → `modules/tools.nix` |
| yazi | ✅ | `programs.yazi` | MEDIUM | ✅ **Converted** | Terminal file manager → `modules/tools.nix` |
| btop | ✅ | `programs.btop` | MEDIUM | ✅ **Converted** | System monitor → `modules/tools.nix` |
| ripgrep | ✅ | `programs.ripgrep` | MEDIUM | ⏭️ **Skipped** | Fast grep alternative - kept as package (minimal config benefit) |
| skim | ✅ | `programs.skim` | LOW | ⏭️ **Skipped** | Fuzzy finder - kept as package (fzf already configured) |
| bottom | ✅ | `programs.bottom` | LOW | ⏭️ **Skipped** | System monitor - kept as package (btop already configured) |

## Tools Remaining as Packages (55 tools)

These tools either lack native HM modules, are simple enough that package installation is sufficient, or were intentionally skipped during implementation.

### Development Tools (8)
- **cargo-watch** - Cargo file watcher
- **clang-tools** - C/C++ tooling
- **cmake** - Build system
- **gcc** - GNU compiler
- **ninja** - Build system
- **rustup** - Rust toolchain manager
- **zig** - Zig compiler
- **uv** - Python package manager

### File & Text Processing (19)
- **choose** - Column selector
- **delta** - Git diff viewer (⚙️ configured via `programs.git.delta` in `modules/git.nix`)
- **difftastic** - Structural diff tool
- **dust** - Disk usage analyzer
- **fd** - Find alternative
- **hexyl** - Hex viewer
- **ouch** - Compression tool
- **procs** - Process viewer
- **repgrep** - Grep with replace preview
- **ripgrep** - Fast grep (⏭️ skipped - minimal config benefit)
- **rm-improved** - Safe rm alternative
- **rnr** - Batch renamer
- **runiq** - Uniq alternative
- **ruplacer** - Find and replace
- **sd** - Sed alternative
- **silver-searcher** - Code search (ag)
- **tre-command** - Tree with git awareness
- **tree** - Directory tree viewer
- **xcp** - Copy with progress

### Search & Navigation (3)
- **fselect** - SQL-like file search
- **scout** - Search tool
- **tere** - Terminal file explorer

### Shell Utilities (7)
- **eva** - Calculator
- **just** - Command runner
- **mcfly** - Neural shell history (⏭️ skipped - limited config benefit)
- **navi** - Interactive cheatsheet
- **skim** - Fuzzy finder (⏭️ skipped - fzf already configured)
- **so** - StackOverflow CLI
- **tealdeer** - tldr client (⏭️ skipped - minimal config needed)

### Git Utilities (3)
- **git-absorb** - Automatic git commit fixup
- **gitoxide** - Git implementation in Rust
- **gitui** - Terminal git UI

### VCS Utilities (2)
- **jujutsu** - Modern VCS (⏭️ skipped - user may prefer default config)
- **lazyjj** - Jujutsu TUI

### Terminal & Display (5)
- **fastfetch** - System info
- **glow** - Markdown viewer
- **lemmeknow** - Data identifier
- **television** - Terminal fuzzy finder
- **tokei** - Code statistics

### System Tools (3)
- **bottom** - System monitor (⏭️ skipped - btop already configured)
- **hyperfine** - Benchmarking
- **trippy** - Network diagnostic (traceroute)

### Network & HTTP (2)
- **xh** - HTTP client
- **xxh** - SSH with shell transport

### Misc Tools (4)
- **amazon-q-cli** - AWS AI assistant
- **chezmoi** - Dotfile manager
- **gpg-tui** - GPG TUI
- **httm** - ZFS snapshot browser
- **lsd** - Ls with colors (alternative to eza)
- **mise** - Dev environment manager
- **rust-parallel** - Parallel command execution
- **vaultwarden** - Password manager server

## Implementation Strategy (Completed)

### Phase 1: Core Shell Environment ✅
Converted the shell and prompt tools first as they provide the most immediate benefit:
- ✅ fish, starship, zoxide, fzf, atuin

### Phase 2: Git Configuration ✅
Git has extensive configuration options that benefit from native module structure:
- ✅ git (with delta integration), lazygit

### Phase 3: Editors & Multiplexers ✅
These have complex configurations that benefit from type checking:
- ✅ neovim, tmux, zellij

### Phase 4: CLI Tools ✅
Converted high-priority utilities:
- ✅ bat, eza, yazi, btop, broot, nushell
- ⏭️ Skipped: mcfly, tealdeer, ripgrep (minimal config benefit)

### Phase 5: Low Priority Evaluation ✅
Decision made on duplicate tools:
- ⏭️ skim - Kept as package (fzf already configured natively)
- ⏭️ bottom - Kept as package (btop already configured natively)
- ⏭️ jujutsu - Kept as package (user may prefer default config)

## Benefits of Native Modules

1. **Type Safety:** Nix type checking catches configuration errors before deployment
2. **Integration:** Better integration with other HM modules (e.g., fish + starship)
3. **Documentation:** Self-documenting configuration with option descriptions
4. **Consistency:** Uniform configuration style across tools
5. **Validation:** Built-in validation for configuration values

## Implementation Notes

### Decisions Made
- ✅ **Delta** - Configured via `programs.git.delta` in `modules/git.nix` (not a separate package)
- ✅ **lsd vs eza** - Kept eza with native module, lsd remains as package for user choice
- ⏭️ **skim vs fzf** - fzf configured natively, skim kept as package for compatibility
- ⏭️ **bottom vs btop** - btop configured natively, bottom kept as package for user choice
- ⏭️ **State management tools** - mise, rustup, chezmoi kept as packages (manage their own complex state)

### Skipped Conversions Rationale
- **mcfly** - Shell history tool with limited configuration options; package installation sufficient
- **tealdeer** - Simple tldr client; minimal configuration benefit from native module
- **jujutsu** - Modern VCS; user may prefer default configuration or manual setup
- **ripgrep** - Fast grep tool; works well as package with minimal configuration needs
- **skim** - Fuzzy finder alternative; fzf already configured, skim kept for compatibility
- **bottom** - System monitor alternative; btop already configured, bottom kept for choice

### Verification Required
Manual verification steps (outside sandbox):
```bash
# Validate Nix configuration
nix flake check

# Build the configuration
darwin-rebuild build --flake .#ray

# Verify module imports
nix eval .#darwinConfigurations.ray.config.home-manager.users.ray.programs.fish.enable
```

### Configuration Structure
```
home-manager/
├── home.nix (main config, imports all modules)
├── modules/
│   ├── shell.nix        (fish, zoxide, fzf, atuin)
│   ├── starship.nix     (cross-shell prompt)
│   ├── git.nix          (git, lazygit, delta)
│   ├── editors.nix      (neovim)
│   ├── multiplexers.nix (tmux, zellij)
│   └── tools.nix        (bat, eza, yazi, btop, broot, nushell)
```
