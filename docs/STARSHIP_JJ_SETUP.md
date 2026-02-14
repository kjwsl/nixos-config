# Modern Starship Config with Jujutsu Support

Complete guide for using the new modern starship configuration with Jujutsu VCS integration.

## What's Included

✅ **Modern, beautiful prompt** with Nord-inspired theme
✅ **Jujutsu (jj) support** via custom modules
✅ **Git integration** with comprehensive status indicators
✅ **Language detection** for 20+ programming languages
✅ **Performance optimized** with selective module loading
✅ **Cloud platform support** (AWS, GCloud, Kubernetes)
✅ **Container detection** (Docker, Nix)

## Installation

The setup includes:
- `jujutsu` - Modern VCS (already installed)
- `jj-starship` - Starship integration for Jujutsu
- `lazyjj` - TUI for Jujutsu (already installed)

### Quick Start

1. **Switch to modern config:**
```bash
# Backup current config
mv starship.toml starship.toml.backup

# Use modern config
mv starship-modern.toml starship.toml

# Rebuild home-manager
home-manager switch --flake .#darwin-development
```

2. **Verify installation:**
```bash
# Check Starship
starship --version

# Check Jujutsu
jj --version

# Check jj-starship
jj-starship --version
```

3. **Initialize a Jujutsu repo to test:**
```bash
# Convert existing git repo
jj git init --git-repo=.

# Or create new jj repo
mkdir test-jj && cd test-jj
jj git init

# Make a change to see the prompt
echo "test" > file.txt
jj status
```

## Features Breakdown

### Visual Design

**Two-line prompt:**
```
╭─ user@host ~/project  main ✓  󱄅 nix-shell  2.3s 14:30:45
╰─❯
```

**Elements:**
- Box drawing characters for clean structure
- Bold colors with Nord theme palette
- Icons from Nerd Fonts for visual clarity
- Contextual information on right side

### Jujutsu Integration

The config includes two custom modules for Jujutsu:

**1. Branch/Bookmark Display (`custom.jj_branch`)**
- Shows current Jujutsu bookmarks
- Icon:   (magenta)
- Command: `jj log -r @ --no-graph -T 'bookmarks.join(", ")'`

**2. Status Display (`custom.jj_status`)**
- Powered by `jj-starship` binary
- Shows working copy changes
- Styled in yellow for visibility

**Example prompt with jj:**
```
╭─ ~/my-project   feature-branch ?2 !1  2.1s
╰─❯
```

### Git vs Jujutsu

The prompt **auto-detects** which VCS you're using:

| Repository Type | Display |
|----------------|---------|
| Git only | Git branch + status |
| Jujutsu only | JJ bookmarks + status |
| Hybrid (jj-git) | Both displayed |

### Command Duration

Shows execution time for long commands:
- **Threshold**: 2+ seconds
- **Format**: ` 3.5s`
- **Color**: Yellow

### Language Detection

Automatically shows active language/runtime:

| Language | Icon | Trigger Files |
|----------|------|---------------|
| Node.js | `` | package.json, .nvmrc |
| Python | `` | *.py, requirements.txt |
| Rust | `` | Cargo.toml |
| Go | `` | go.mod |
| Nix | `󱄅` | *.nix, flake.nix |
| Docker | `` | Dockerfile |

**Plus**: Java, Kotlin, Lua, C, Elixir, Haskell, Ruby, Scala, Swift, Zig

### Status Indicators

**Git Status:**
- `?` - Untracked files
- `!` - Modified files
- `+` - Staged files
- `✘` - Deleted files
- `»` - Renamed files
- `󰏗` - Stashed changes
- `⇡` - Ahead of remote
- `⇣` - Behind remote
- `✓` - Up to date

**System:**
- `` - Background jobs
- `󰂃` - Battery status (if < 30%)
- `⬢` - Container environment
- `✖` - Failed command (with exit code)

## Performance Optimization

The config is optimized for speed:

1. **Lazy loading**: Language modules only activate in relevant directories
2. **Minimal checks**: 2s threshold for command duration
3. **Efficient queries**: JJ status via fast binary
4. **Selective display**: SSH-only hostname, threshold-based battery

## Customization

### Change Theme Colors

Edit the `[palettes.modern]` section:

```toml
[palettes.modern]
bg_dark = "#2E3440"     # Dark background
bg_light = "#3B4252"    # Light background
fg = "#ECEFF4"          # Foreground text
accent = "#88C0D0"      # Primary accent (cyan)
success = "#A3BE8C"     # Success (green)
error = "#BF616A"       # Error (red)
purple = "#B48EAD"      # JJ branch color
```

**Popular alternatives:**
- **Catppuccin**: Mocha, Latte, Frappe, Macchiato
- **Dracula**: Dark purple theme
- **Tokyo Night**: Dark blue theme
- **Gruvbox**: Retro groove colors

### Adjust JJ Status Detail

Modify the `custom.jj_status` command:

```toml
[custom.jj_status]
command = '''
jj-starship status --verbose  # More detail
# or
jj status --no-pager          # Use native jj
'''
```

### Disable Language Modules

Add `.disabled = true` for unwanted languages:

```toml
[python]
disabled = true

[nodejs]
disabled = true
```

### Add Custom Modules

Example - Show todo count:

```toml
[custom.todo]
command = "grep -c TODO **/*.rs 2>/dev/null || echo 0"
when = "test -f Cargo.toml"
format = "[ $output]($style) "
style = "bold yellow"
description = "Count TODO comments in Rust project"
```

## Jujutsu Workflow

### Basic Commands

```bash
# Initialize
jj git init --git-repo=.

# View status
jj status

# Create bookmark (branch)
jj bookmark create feature-name

# Describe changes
jj describe -m "Add feature X"

# Create new change
jj new

# View log
jj log

# Sync with Git
jj git fetch
jj git push
```

### The prompt will show:

```bash
# Clean state
~/project   main ✓

# Uncommitted changes
~/project   main ?2 !1

# Multiple bookmarks
~/project   main, feature ✓
```

## Alternatives to Starship

If you want something even faster or different:

### 1. Oh My Posh (Fastest)

**Pros:**
- Faster than Starship (async updates)
- Polished themes
- GUI config editor

**Cons:**
- Larger binary
- More complex config

**Install:**
```nix
home.packages = with pkgs; [
  oh-my-posh
];

programs.fish.interactiveShellInit = ''
  oh-my-posh init fish | source
'';
```

**Resources:**
- [Oh My Posh Themes](https://ohmyposh.dev/docs/themes)
- [NixOS discussions](https://github.com/JanDeDobbeleer/oh-my-posh/discussions/1293)

### 2. Powerlevel10k (Zsh only)

**Pros:**
- Extremely fast
- Rich features
- Instant prompt

**Cons:**
- Zsh only (you use Fish)
- On life support (maintainer stepping back)

**Not recommended** - [Project status](https://hashir.blog/2025/06/powerlevel10k-is-on-life-support-hello-starship/)

### 3. Spaceship Prompt

**Pros:**
- Zsh-native
- Lots of modules

**Cons:**
- Slower than Starship
- Zsh only

### Recommendation: Stick with Starship

- Cross-shell (Fish, Bash, Zsh)
- Written in Rust (very fast)
- Active development
- JJ support via custom modules
- You already have it configured!

## Troubleshooting

### JJ status not showing

```bash
# Check if jj-starship is installed
which jj-starship

# Test manually
jj-starship status

# Check if in jj repo
jj workspace root --ignore-working-copy
```

### Icons not displaying

Install a Nerd Font:
```bash
# Via home-manager
fonts.fontconfig.enable = true;

# Manual install (macOS)
brew install --cask font-jetbrains-mono-nerd-font
# or
brew install --cask font-fira-code-nerd-font
```

**Configure terminal** to use the Nerd Font.

### Prompt too slow

```bash
# Profile starship
starship timings

# Disable slow modules
# Add to starship.toml:
[some_slow_module]
disabled = true
```

### JJ bookmarks not showing

```bash
# Create a bookmark first
jj bookmark create main

# Or track Git branches
jj bookmark track main@origin
```

## Advanced: Oh My Posh Migration

If you want to try Oh My Posh:

```bash
# Export Starship config as base
starship config

# Generate Oh My Posh equivalent
oh-my-posh init fish --print

# Use similar theme
oh-my-posh init fish --config ~/.config/ohmyposh/nord.json | source
```

## Resources

**Starship:**
- Official Site: https://starship.rs/
- Config Docs: https://starship.rs/config/
- Preset Configs: https://starship.rs/presets/

**Jujutsu:**
- Official Site: https://jj-vcs.github.io/jj/
- Tutorial: https://jj-vcs.github.io/jj/latest/tutorial/
- Git Comparison: https://jj-vcs.github.io/jj/latest/git-comparison/

**Integrations:**
- jj-starship: https://github.com/prasant081/jj-starship
- Native JJ module PR: https://github.com/starship/starship/pull/6969

**Alternatives:**
- Oh My Posh: https://ohmyposh.dev/
- Spaceship: https://spaceship-prompt.sh/
- Powerlevel10k: https://github.com/romkatv/powerlevel10k

## Next Steps

1. **Activate the config**: Rebuild home-manager
2. **Test with JJ**: Initialize a repo and make changes
3. **Customize colors**: Adjust the palette to your preference
4. **Add custom modules**: Extend with your own indicators
5. **Share your config**: Contribute improvements!

**Enjoy your modern, beautiful prompt! 🚀**
