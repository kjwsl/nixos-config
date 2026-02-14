#!/bin/bash
# Comprehensive Backup Script
# Backs up: Serena memories, Thunderbird, Bitwarden, and project configs

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
BACKUP_DIR="${BACKUP_DIR:-$HOME/Backups/$(date +%Y-%m-%d_%H-%M-%S)}"
PROJECT_DIR="$HOME/repos/home-manager"

echo -e "${GREEN}🔐 Comprehensive Backup Script${NC}"
echo -e "Backup destination: ${YELLOW}${BACKUP_DIR}${NC}"
echo ""

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Function to backup with progress
backup_item() {
    local source="$1"
    local dest="$2"
    local name="$3"

    if [ -e "$source" ]; then
        echo -e "${YELLOW}Backing up ${name}...${NC}"
        rsync -a --info=progress2 "$source" "$dest/" 2>/dev/null || cp -r "$source" "$dest/"
        echo -e "${GREEN}✓ ${name} backed up${NC}"
        return 0
    else
        echo -e "${RED}✗ ${name} not found at: ${source}${NC}"
        return 1
    fi
}

# 1. Serena Memories
echo -e "\n${GREEN}=== Serena Memories ===${NC}"
if [ -d "$PROJECT_DIR/.serena" ]; then
    backup_item "$PROJECT_DIR/.serena" "$BACKUP_DIR" "Serena memories"

    # List backed up memories
    echo -e "${YELLOW}Memory files:${NC}"
    find "$BACKUP_DIR/.serena/memories" -name "*.md" -exec basename {} \; 2>/dev/null | sed 's/^/  - /'
else
    echo -e "${RED}No Serena memories found${NC}"
fi

# 2. Thunderbird Emails
echo -e "\n${GREEN}=== Thunderbird Emails ===${NC}"
THUNDERBIRD_DIR="$HOME/Library/Thunderbird"

# Thunderbird stores profiles in ~/Library/Thunderbird/Profiles/
if [ -d "$THUNDERBIRD_DIR/Profiles" ]; then
    backup_item "$THUNDERBIRD_DIR/Profiles" "$BACKUP_DIR/thunderbird/Profiles" "Thunderbird profiles"

    # Get profile size
    PROFILE_SIZE=$(du -sh "$THUNDERBIRD_DIR/Profiles" 2>/dev/null | awk '{print $1}')
    echo -e "${YELLOW}Total size: ${PROFILE_SIZE}${NC}"

    # List profiles
    echo -e "${YELLOW}Profiles backed up:${NC}"
    ls -1 "$THUNDERBIRD_DIR/Profiles" 2>/dev/null | sed 's/^/  - /'

    # Backup profiles.ini
    if [ -f "$THUNDERBIRD_DIR/profiles.ini" ]; then
        backup_item "$THUNDERBIRD_DIR/profiles.ini" "$BACKUP_DIR/thunderbird" "Thunderbird profiles.ini"
    fi
else
    echo -e "${RED}No Thunderbird profiles found at: $THUNDERBIRD_DIR/Profiles${NC}"
fi

# 3. Himalaya Email Client
echo -e "\n${GREEN}=== Himalaya Email Client ===${NC}"

# Check if Himalaya is installed
if command -v himalaya &> /dev/null; then
    echo -e "${GREEN}Himalaya installed: $(himalaya --version | head -1)${NC}"

    # Backup Himalaya config and cache (macOS paths)
    HIMALAYA_CONFIG="$HOME/Library/Application Support/himalaya"
    HIMALAYA_CACHE="$HOME/Library/Caches/himalaya"

    if [ -d "$HIMALAYA_CONFIG" ]; then
        backup_item "$HIMALAYA_CONFIG" "$BACKUP_DIR/himalaya" "Himalaya config"

        # Show account info
        if [ -f "$HIMALAYA_CONFIG/config.toml" ]; then
            echo -e "${YELLOW}Accounts configured:${NC}"
            himalaya accounts list 2>/dev/null | tail -n +3 | sed 's/^/  /'
        fi
    else
        echo -e "${YELLOW}No Himalaya config found at: $HIMALAYA_CONFIG${NC}"
    fi

    # Backup cache if exists
    if [ -d "$HIMALAYA_CACHE" ]; then
        backup_item "$HIMALAYA_CACHE" "$BACKUP_DIR/himalaya-cache" "Himalaya cache"
    fi

    # Export account list
    echo -e "${YELLOW}Saving account configuration...${NC}"
    himalaya accounts list > "$BACKUP_DIR/himalaya/accounts.txt" 2>/dev/null || echo -e "${YELLOW}Could not export accounts${NC}"
else
    echo -e "${YELLOW}Himalaya not installed${NC}"
fi

# 4. Bitwarden
echo -e "\n${GREEN}=== Bitwarden ===${NC}"
BITWARDEN_DIR="$HOME/Library/Application Support/Bitwarden"

if [ -d "$BITWARDEN_DIR" ]; then
    # Backup encrypted vault
    backup_item "$BITWARDEN_DIR/data.json" "$BACKUP_DIR/bitwarden" "Bitwarden vault (encrypted)"

    # Try to export unencrypted backup via CLI (if logged in)
    if command -v bw &> /dev/null; then
        echo -e "${YELLOW}Attempting Bitwarden CLI export...${NC}"

        # Check if logged in
        if bw login --check &> /dev/null; then
            echo -e "${YELLOW}Enter your Bitwarden master password:${NC}"

            # Export to JSON
            if bw export --format json --output "$BACKUP_DIR/bitwarden/vault-export.json"; then
                echo -e "${GREEN}✓ Unencrypted export created${NC}"
                echo -e "${RED}⚠️  WARNING: vault-export.json is UNENCRYPTED!${NC}"
                echo -e "${YELLOW}Keep this backup secure and delete after use!${NC}"
            else
                echo -e "${YELLOW}Export failed (incorrect password or session expired)${NC}"
            fi
        else
            echo -e "${YELLOW}Bitwarden CLI not logged in (skipping export)${NC}"
            echo -e "${YELLOW}To export: bw login && bw export${NC}"
        fi
    else
        echo -e "${YELLOW}Bitwarden CLI not installed${NC}"
        echo -e "${YELLOW}Install: brew install bitwarden-cli${NC}"
    fi

    # Backup all Bitwarden app data
    backup_item "$BITWARDEN_DIR" "$BACKUP_DIR/bitwarden-app" "Bitwarden app data"
else
    echo -e "${RED}Bitwarden data not found${NC}"
fi

# 5. Home Manager Config
echo -e "\n${GREEN}=== Home Manager Config ===${NC}"
backup_item "$PROJECT_DIR" "$BACKUP_DIR" "home-manager project"

# Exclude large directories
if [ -d "$BACKUP_DIR/home-manager" ]; then
    echo -e "${YELLOW}Excluding build artifacts...${NC}"
    rm -rf "$BACKUP_DIR/home-manager/result" \
           "$BACKUP_DIR/home-manager/.direnv" \
           "$BACKUP_DIR/home-manager/node_modules" 2>/dev/null || true
fi

# 6. SSH Keys (optional but recommended)
echo -e "\n${GREEN}=== SSH Keys ===${NC}"
read -p "Backup SSH keys? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    backup_item "$HOME/.ssh" "$BACKUP_DIR" "SSH keys"
    echo -e "${RED}⚠️  SSH keys are backed up - keep this backup SECURE!${NC}"
else
    echo -e "${YELLOW}Skipping SSH keys${NC}"
fi

# 7. OpenClaw Config
echo -e "\n${GREEN}=== OpenClaw Config ===${NC}"
if [ -d "$HOME/.openclaw" ]; then
    backup_item "$HOME/.openclaw" "$BACKUP_DIR" "OpenClaw config"
else
    echo -e "${YELLOW}No OpenClaw config found${NC}"
fi

# Create backup manifest
echo -e "\n${GREEN}=== Creating Backup Manifest ===${NC}"
cat > "$BACKUP_DIR/MANIFEST.txt" << EOF
Backup Manifest
===============

Date: $(date)
Hostname: $(hostname)
User: $(whoami)
Backup Location: ${BACKUP_DIR}

Contents:
---------
$(find "$BACKUP_DIR" -type d -maxdepth 1 ! -path "$BACKUP_DIR" -exec basename {} \; | sort | sed 's/^/  - /')

Total Size: $(du -sh "$BACKUP_DIR" | awk '{print $1}')

Files Included:
---------------
$(find "$BACKUP_DIR" -type f | wc -l) files

Restoration Notes:
------------------
1. Serena Memories: Copy .serena/ back to project directory
2. Thunderbird: Copy Profiles/ to ~/Library/Application Support/Thunderbird/
3. Bitwarden: Copy data.json to ~/Library/Application Support/Bitwarden/
   OR restore from vault-export.json via CLI: bw import bitwarden-json vault-export.json
4. Home Manager: Copy entire directory or restore specific files
5. SSH: Copy .ssh/ to home directory and chmod 600 keys
6. OpenClaw: Copy .openclaw/ to home directory

Security Reminders:
-------------------
⚠️  This backup may contain:
   - Encrypted passwords (Bitwarden data.json) - SAFE
   - Unencrypted passwords (vault-export.json) - DANGER! Delete after use
   - SSH private keys - Keep secure!
   - Email archives - May contain sensitive data

🔐 Store this backup in a secure location:
   - Encrypted external drive
   - Encrypted cloud storage (with client-side encryption)
   - Encrypted USB drive in safe location

❌ DO NOT:
   - Upload to unencrypted cloud storage
   - Leave on shared computers
   - Send via email or messaging apps
EOF

echo -e "${GREEN}✓ Manifest created${NC}"

# Compression (optional)
echo -e "\n${GREEN}=== Compression ===${NC}"
read -p "Compress backup to .tar.gz? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ARCHIVE_NAME="backup-$(date +%Y-%m-%d_%H-%M-%S).tar.gz"
    echo -e "${YELLOW}Creating archive: ${ARCHIVE_NAME}${NC}"

    tar -czf "$HOME/Backups/$ARCHIVE_NAME" -C "$BACKUP_DIR/.." "$(basename "$BACKUP_DIR")"

    echo -e "${GREEN}✓ Archive created: $HOME/Backups/$ARCHIVE_NAME${NC}"

    read -p "Delete uncompressed backup? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$BACKUP_DIR"
        echo -e "${GREEN}✓ Uncompressed backup deleted${NC}"
    fi
fi

# Summary
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Backup Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
if [ -f "$HOME/Backups/$ARCHIVE_NAME" ]; then
    echo -e "📦 Archive: ${YELLOW}$HOME/Backups/$ARCHIVE_NAME${NC}"
    echo -e "📊 Size: ${YELLOW}$(du -sh "$HOME/Backups/$ARCHIVE_NAME" | awk '{print $1}')${NC}"
else
    echo -e "📁 Backup: ${YELLOW}${BACKUP_DIR}${NC}"
    echo -e "📊 Size: ${YELLOW}$(du -sh "$BACKUP_DIR" | awk '{print $1}')${NC}"
fi
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Copy backup to secure external storage"
echo -e "2. Verify backup integrity"
echo -e "3. Test restoration on a non-critical system (optional)"
echo -e "4. ${RED}Delete vault-export.json if created${NC}"
echo ""
