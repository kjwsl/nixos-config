#!/bin/bash
# Quick Backup - Just the essentials (no interactive prompts)

BACKUP_DIR="$HOME/Backups/quick-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "🔐 Quick Backup to: $BACKUP_DIR"

# Serena memories
if [ -d ~/repos/home-manager/.serena ]; then
    cp -r ~/repos/home-manager/.serena "$BACKUP_DIR/" && echo "✓ Serena"
fi

# Bitwarden
if [ -f ~/Library/Application\ Support/Bitwarden/data.json ]; then
    mkdir -p "$BACKUP_DIR/bitwarden"
    cp ~/Library/Application\ Support/Bitwarden/data.json "$BACKUP_DIR/bitwarden/" && echo "✓ Bitwarden"
fi

# OpenClaw
if [ -d ~/.openclaw ]; then
    cp -r ~/.openclaw "$BACKUP_DIR/" && echo "✓ OpenClaw"
fi

# Home manager key configs
cp ~/repos/home-manager/home.nix "$BACKUP_DIR/" 2>/dev/null && echo "✓ home.nix"
cp ~/repos/home-manager/flake.nix "$BACKUP_DIR/" 2>/dev/null && echo "✓ flake.nix"

# Create archive
tar -czf "$HOME/Backups/quick-backup-$(date +%Y%m%d).tar.gz" -C "$HOME/Backups" "$(basename "$BACKUP_DIR")"
rm -rf "$BACKUP_DIR"

echo "✅ Backup complete: ~/Backups/quick-backup-$(date +%Y%m%d).tar.gz"
echo "Size: $(du -sh ~/Backups/quick-backup-$(date +%Y%m%d).tar.gz | awk '{print $1}')"
