# 🚀 Advanced Tmux Configuration - Keybindings & Features

## 🎨 Visual Features
- **Catppuccin Mocha Theme** - Modern, beautiful colors
- **CPU & Battery Monitoring** - Live system stats in status bar
- **Mode Indicator** - Visual feedback for WAIT/COPY/SYNC modes
- **Smart Pane Borders** - Cyan highlighting for active pane

## ⌨️ Essential Keybindings

### Prefix Key
- `Ctrl-a` - Prefix (not Ctrl-b)

### Pane Management
- `Prefix + |` - Split pane horizontally
- `Prefix + -` - Split pane vertically
- `Prefix + h/j/k/l` - Navigate panes (Vi-style)
- `Prefix + H/J/K/L` - Resize panes
- `Prefix + Tab` - Cycle through panes
- `Prefix + z` - Zoom/unzoom pane
- `Prefix + b` - Break pane to new window
- `Prefix + j` - Join pane from another window
- `Prefix + s` - Send pane to another window
- `Prefix + Ctrl-o` - Swap with marked pane
- `Prefix + Ctrl-s` - Synchronize panes (type in all at once!)

### Neovim Integration (NO PREFIX NEEDED!)
- `Ctrl-h/j/k/l` - Smart navigation (works with Neovim splits)
- `Alt-h/j/k/l` - Smart resizing (works with Neovim splits)

### Window Management
- `Prefix + c` - New window (in current path)
- `Prefix + Ctrl-h` - Previous window
- `Prefix + Ctrl-l` - Next window
- `Prefix + <` - Swap window left
- `Prefix + >` - Swap window right
- `Prefix + 1-9` - Select window by number

### Session Management
- `Prefix + S` - Choose session (interactive)
- `Prefix + (` - Previous session
- `Prefix + )` - Next session

### Layout Shortcuts
- `Prefix + Alt-1` - Even horizontal layout
- `Prefix + Alt-2` - Even vertical layout
- `Prefix + Alt-3` - Main horizontal layout
- `Prefix + Alt-4` - Main vertical layout
- `Prefix + Alt-5` - Tiled layout

### Copy Mode (Vi-style)
- `Prefix + [` - Enter copy mode
- `v` - Begin selection
- `Ctrl-v` - Rectangle selection
- `y` - Copy selection (to clipboard!)
- `/` - Search forward
- `?` - Search backward
- `Prefix + u` - Open URLs with fzf (fuzzy finder!)

### Search & Navigation
- `Prefix + Ctrl-f` - Search files (copycat)
- `Prefix + Ctrl-u` - Search URLs (copycat)
- `Prefix + Alt-h` - Search SHA-1 hashes (copycat)
- `Prefix + o` - Open selection (files/URLs)

### Utilities
- `Prefix + r` - Reload config
- `Prefix + Ctrl-k` - Clear screen & history
- `Prefix + m` - Toggle mouse mode
- `Prefix + ?` - Show all keybindings

## 🔌 Powerful Plugins Installed

### Core Functionality
- **tmux-sensible** - Sane defaults
- **tmux-pain-control** - Better pane control
- **tmux-resurrect** - Save/restore sessions (survives reboots!)
- **tmux-continuum** - Auto-save every 15 minutes

### Navigation & Search
- **tmux-copycat** - Regex search & highlights
- **tmux-open** - Open files/URLs from terminal
- **tmux-fzf-url** - Fuzzy find URLs (Prefix + u)

### Visual & Info
- **tmux-battery** - Battery indicator with moon phases 🌕
- **tmux-cpu** - CPU usage with color indicators
- **tmux-mode-indicator** - Shows current mode
- **tmux-prefix-highlight** - Highlights when prefix is active
- **catppuccin** - Beautiful theme

### Clipboard
- **tmux-yank** - Enhanced clipboard integration

## 💾 Session Persistence

Your tmux sessions are automatically saved every 15 minutes and restored when you restart tmux!

- Sessions survive system reboots
- Pane contents are saved
- Working directories preserved
- Special processes (ssh, mysql, psql) are tracked

## 🎯 Pro Tips

1. **Synchronize Panes** - `Prefix + Ctrl-s` lets you type in multiple panes at once (great for managing multiple servers!)

2. **URL Opening** - `Prefix + u` opens a fuzzy finder with all URLs in your scrollback. Navigate and open instantly!

3. **Quick Layouts** - Use `Prefix + Alt-1` through `Alt-5` to instantly switch between common layouts

4. **Mouse Toggle** - If mouse gets in the way, toggle it with `Prefix + m`

5. **Neovim Integration** - `Ctrl-h/j/k/l` seamlessly navigates between tmux panes AND Neovim splits!

6. **Status Bar Info** - Your status bar shows:
   - Current directory
   - Application name
   - Session name
   - CPU usage (with color warnings)
   - Battery status
   - Current time

## 🔍 Search Features

**In Copy Mode:**
- Search for file paths, URLs, git SHAs automatically
- Highlighted matches
- Press `o` to open selected file/URL

**URL Fuzzy Finder:**
- Press `Prefix + u`
- Fuzzy search through last 2000 URLs
- Press Enter to open in browser

## 🌈 Theme Customization

Want a different color? Edit `@catppuccin_flavour`:
- `latte` - Light theme
- `frappe` - Soft dark
- `macchiato` - Medium dark
- `mocha` - Deep dark (current)

## 📊 System Monitoring

Status bar automatically shows:
- **CPU**: ✓ (low), ⚠ (medium), ✗ (high)
- **Battery**: Moon phases for charge level, ⚡ when charging

Enjoy your supercharged tmux! 🎉
