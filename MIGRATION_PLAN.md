# Chezmoi → Nix Home-Manager Migration Plan

**Goal**: Migrate from dual system (Nix packages + chezmoi dotfiles) to Nix-first approach with mutable configs.

## Phase 1: Categorization (✅ DONE)

### Keep in Chezmoi (Temporary - will migrate)
**Shell configs** (migrate to Nix):
- fish: .config/fish/*
- nushell: .config/nushell/* (already in repo/dotfiles/nushell!)
- bash: .bashrc, .bash_local, .aliasrc
- zsh: .zshrc, .zshenv

**Editor configs** (keep mutable):
- nvim: .config/nvim/* (symlink to repo)
- helix: .config/helix/*
- doom: .config/doom/*
- zed: .config/zed/*
- ideavim: .config/ideavim/ideavimrc

**Terminal configs** (mix):
- wezterm: .config/wezterm/* (keep mutable)
- ghostty: .config/ghostty/* (keep mutable)
- kitty: .config/kitty/*
- alacritty: .config/alacritty/*

**Dev tools** (migrate to Nix):
- git: .config/git/config
- jj: .config/jj/config.toml
- lazygit: .config/lazygit/config.yml
- tmux: .config/tmux/*
- zellij: .config/zellij/*

**macOS-specific** (keep mutable):
- aerospace: .config/aerospace/aerospace.toml
- karabiner: .config/karabiner/*
- sketchybar: .config/sketchybar/*

**CLI tool configs** (migrate to Nix):
- btop: .config/btop/*
- yazi: .config/yazi/*
- starship: .config/starship.toml
- fastfetch: .config/fastfetch/*

### Remove from Chezmoi (Don't belong)
**Binary files** (manage separately):
- .vst/*, .vst3/* (hundreds of VST plugins)
- .clap/* (audio plugins)
- .fonts/* (already in Nix: font-jetbrains-mono-nerd-font)
- binaries/* (use Nix packages instead)

**Platform-specific wrong platform**:
- .config/cinnamon/* (Linux desktop on macOS!)
- .config/waybar/* (Wayland on macOS!)
- .config/hypr/* (Hyprland on macOS!)
- AppData/* (Windows paths on macOS!)

**Temporary/cache files**:
- .config/pulse/* (runtime state)
- .config/ibus/* (runtime state)
- .config/syncthing/*.pem (secrets - use sops-nix)
- .config/zed/conversations/* (session data)

**Duplicate configs** (already in repo):
- .config/nushell/* (repo/dotfiles/nushell exists!)

## Phase 2: Create Modular Nix Structure

```
home/
├── home.nix                  # Main entry (imports everything)
├── packages.nix              # Package list (already exists)
├── programs/                 # Program configurations
│   ├── shells.nix           # bash, fish, nushell, zsh
│   ├── git.nix              # git, jj, lazygit
│   ├── terminals.nix        # terminal emulator settings
│   ├── editors.nix          # editor settings (where possible)
│   ├── cli-tools.nix        # btop, yazi, starship, etc.
│   └── tmux.nix             # tmux, zellij
├── platform/                 # Platform-specific
│   ├── darwin.nix           # macOS-specific settings
│   └── linux.nix            # Linux-specific settings
└── dotfiles.nix             # Mutable config symlinks
```

## Phase 3: Migration Steps

### Step 1: Migrate Shell Configs to Nix (First priority)
**Files**: .bashrc, .zshrc, fish configs, nushell configs

**Action**:
- Create `home/programs/shells.nix`
- Move aliases, env vars, shell options to Nix
- Keep custom scripts in repo for sourcing

**Expected**: 30-50% reduction in chezmoi files

### Step 2: Migrate Git/VCS Configs
**Files**: .config/git/config, .config/jj/config.toml, .config/lazygit/config.yml

**Action**:
- Create `home/programs/git.nix`
- Move git config to Nix declarative format
- Move jj config to Nix

**Expected**: Clear single source of truth for VCS

### Step 3: Migrate CLI Tool Configs
**Files**: btop, yazi, starship, fastfetch configs

**Action**:
- Create `home/programs/cli-tools.nix`
- Use home-manager's native modules where available
- Inline configs for tools without modules

**Expected**: Eliminate ~20 config files

### Step 4: Set Up Mutable Symlinks
**Files**: nvim, wezterm, ghostty, aerospace, karabiner

**Action**:
- Create `home/dotfiles.nix`
- Symlink frequently-edited configs to repo
- Keep them mutable (no rebuild needed)

**Expected**: Edit without rebuild, still version controlled

### Step 5: Clean Up Chezmoi
**Action**:
- Remove VST plugins from chezmoi
- Remove fonts from chezmoi
- Remove platform-specific wrong platform configs
- Remove binaries
- Keep only secrets (if any)

**Expected**: 799 → ~50 files, maybe eliminate chezmoi entirely

## Phase 4: New Workflow

### Daily workflow:
```bash
# Edit mutable configs (no rebuild)
nvim ~/.config/wezterm/wezterm.lua  # Direct edit

# Change packages or Nix configs
cd ~/repos/home-manager
nvim home/programs/shells.nix       # Edit Nix config
just darwin                          # Rebuild (or auto with direnv)
```

### Cross-platform deployment:
```bash
# On new macOS machine
git clone https://github.com/you/home-manager
cd home-manager
just darwin

# On new Linux machine
git clone https://github.com/you/home-manager
cd home-manager
just linux

# Everything just works™
```

## Phase 5: Chezmoi Elimination Decision

**Option A: Keep chezmoi for secrets only**
- Use chezmoi ONLY for API keys, tokens, SSH configs with different keys per machine
- Everything else in Nix

**Option B: Full Nix (use sops-nix for secrets)**
- Eliminate chezmoi entirely
- Use sops-nix for encrypted secrets
- 100% Nix-based system

**Recommendation**: Option B - full Nix with sops-nix

## Success Metrics

- ✅ Single `just darwin` command deploys entire system
- ✅ Configs editable without rebuild (mutable symlinks)
- ✅ <100 total dotfiles (from 799)
- ✅ Zero platform-specific configs on wrong platform
- ✅ No binary files in version control
- ✅ Clear separation: Nix manages structure, repo holds content

## Timeline

- **Phase 1**: ✅ Already done (this document)
- **Phase 2-3**: 2-4 hours (create structure + migrate shells/git)
- **Phase 4**: 1 hour (set up mutable symlinks)
- **Phase 5**: 30 min (clean up chezmoi)

**Total**: Half day of focused work for complete migration
