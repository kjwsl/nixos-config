# Backup & Restoration Guide

Complete guide for backing up and restoring all important data.

## 🔐 What Gets Backed Up

### 1. Serena Memories (Project Context)
**Location:** `/Users/ray/repos/home-manager/.serena/memories/`
**Size:** ~100KB
**Contains:**
- Session histories
- Pattern discoveries
- Technical learnings
- Project context

### 2. Thunderbird Emails
**Location:** `~/Library/Thunderbird/Profiles/`
**Size:** Varies (can be several GB)
**Contains:**
- All email accounts
- Contacts
- Calendar events
- Email filters and settings
- Local email storage (IMAP cache)

### 3. Bitwarden Vault
**Location:** `~/Library/Application Support/Bitwarden/data.json`
**Size:** <1MB (encrypted)
**Contains:**
- All passwords (encrypted)
- Secure notes
- Identity information
- Payment cards

### 4. Home Manager Config
**Location:** `/Users/ray/repos/home-manager/`
**Size:** ~10MB
**Contains:**
- All nix configurations
- Scripts and documentation
- Profile settings

### 5. SSH Keys (Optional)
**Location:** `~/.ssh/`
**Size:** <1MB
**Contains:**
- Private/public key pairs
- Known hosts
- SSH config

### 6. Himalaya Email Client
**Location:** `~/Library/Application Support/himalaya/`
**Size:** ~4KB (config only, emails on server)
**Contains:**
- Account configuration (IMAP/SMTP)
- Password stored in macOS Keychain
- No local email storage (IMAP-only)

### 7. OpenClaw Config
**Location:** `~/.openclaw/`
**Size:** ~100MB
**Contains:**
- OAuth credentials
- Configuration
- Session data and cache

---

## 🚀 Quick Backup

### One-Command Backup
```bash
cd ~/repos/home-manager
./scripts/backup-all.sh
```

**Interactive prompts:**
1. Backup SSH keys? (y/n)
2. Compress to .tar.gz? (y/n)
3. Delete uncompressed backup? (y/n)

**Output:** `~/Backups/YYYY-MM-DD_HH-MM-SS/` or `.tar.gz` archive

### Quick Essentials-Only Backup
```bash
# Just the critical stuff (no emails)
mkdir -p ~/Backups/quick-backup
cp -r ~/repos/home-manager/.serena ~/Backups/quick-backup/
cp -r ~/.openclaw ~/Backups/quick-backup/
cp ~/Library/Application\ Support/Bitwarden/data.json ~/Backups/quick-backup/bitwarden-vault.json
tar -czf ~/Backups/quick-backup-$(date +%Y%m%d).tar.gz -C ~/Backups quick-backup
rm -rf ~/Backups/quick-backup
```

---

## 📥 Restoration

### 1. Restore Serena Memories
```bash
# Extract backup
cd ~/Backups
tar -xzf backup-YYYY-MM-DD.tar.gz

# Copy to project
cp -r backup-YYYY-MM-DD/.serena ~/repos/home-manager/

# Verify
cd ~/repos/home-manager
mise exec -- serena list_memories
```

### 2. Restore Thunderbird
```bash
# Stop Thunderbird first!
killall thunderbird 2>/dev/null || true

# Restore profiles (correct location on macOS)
cp -r backup-YYYY-MM-DD/thunderbird/Profiles/* \
  ~/Library/Thunderbird/Profiles/

# Restore profiles.ini
cp backup-YYYY-MM-DD/thunderbird/profiles.ini \
  ~/Library/Thunderbird/

# Start Thunderbird
open -a Thunderbird
```

### 2b. Restore Himalaya
```bash
# Restore config
cp -r backup-YYYY-MM-DD/himalaya/* \
  ~/Library/Application\ Support/himalaya/

# Password is in macOS Keychain (already backed up with system)
# No restoration needed - just verify login works
himalaya accounts list
```

### 3. Restore Bitwarden

**Option A: Restore encrypted vault (safest)**
```bash
# Quit Bitwarden
killall Bitwarden 2>/dev/null || true

# Restore encrypted vault
cp backup-YYYY-MM-DD/bitwarden/data.json \
  ~/Library/Application\ Support/Bitwarden/

# Start Bitwarden and unlock with master password
open -a Bitwarden
```

**Option B: Import from unencrypted export (if you created one)**
```bash
# Login to Bitwarden CLI
bw login

# Import vault
bw import bitwarden-json backup-YYYY-MM-DD/bitwarden/vault-export.json

# CRITICAL: Delete the unencrypted export!
rm backup-YYYY-MM-DD/bitwarden/vault-export.json
```

### 4. Restore Home Manager
```bash
# Full restoration
cp -r backup-YYYY-MM-DD/home-manager ~/repos/

# Or selective restoration
cp backup-YYYY-MM-DD/home-manager/home.nix ~/repos/home-manager/
cp -r backup-YYYY-MM-DD/home-manager/modules ~/repos/home-manager/

# Rebuild
cd ~/repos/home-manager
home-manager switch --flake .#darwin-development
```

### 5. Restore SSH Keys
```bash
# Copy keys
cp -r backup-YYYY-MM-DD/.ssh ~/

# Fix permissions (CRITICAL!)
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub

# Test
ssh -T git@github.com
```

### 6. Restore OpenClaw
```bash
cp -r backup-YYYY-MM-DD/.openclaw ~/

# If on AWS instance
scp -r backup-YYYY-MM-DD/.openclaw ec2-user@IP:~/
```

---

## 🔄 Automated Backup Schedule

### Setup Cron Job (Daily Backups)
```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * /Users/ray/repos/home-manager/scripts/backup-all.sh --auto >> /tmp/backup.log 2>&1
```

### Setup LaunchAgent (macOS)
```bash
# Create LaunchAgent
cat > ~/Library/LaunchAgents/com.user.backup.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.backup</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/ray/repos/home-manager/scripts/backup-all.sh</string>
        <string>--auto</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>2</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>/tmp/backup.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/backup-error.log</string>
</dict>
</plist>
EOF

# Load LaunchAgent
launchctl load ~/Library/LaunchAgents/com.user.backup.plist

# Check status
launchctl list | grep backup
```

---

## 📊 Backup Best Practices

### Storage Locations

**✅ Good:**
- External encrypted drive
- Encrypted cloud storage (Cryptomator, rclone with encryption)
- USB drive in safe/lockbox
- Multiple locations (3-2-1 rule)

**❌ Bad:**
- Unencrypted cloud storage (Dropbox, Google Drive without encryption)
- Shared computers
- Email or messaging apps
- Single location only

### 3-2-1 Backup Rule

**3** copies of data
**2** different storage media
**1** copy off-site

Example:
1. Original on Mac
2. External SSD backup
3. Encrypted cloud backup (off-site)

### Encryption Options

**Full Disk Encryption:**
```bash
# macOS FileVault (built-in)
sudo fdesetup enable

# VeraCrypt (cross-platform)
brew install --cask veracrypt
```

**File-Level Encryption:**
```bash
# Encrypt backup with GPG
tar -czf - ~/Backups/backup-YYYY-MM-DD | gpg -c > backup-encrypted.tar.gz.gpg

# Decrypt
gpg -d backup-encrypted.tar.gz.gpg | tar -xzf -
```

**Cloud Encryption:**
```bash
# Install Cryptomator
brew install --cask cryptomator

# Or use rclone with encryption
brew install rclone
rclone config  # Setup encrypted remote
```

---

## 🧪 Testing Backups

### Monthly Backup Verification

**Checklist:**
- [ ] Backup completed without errors
- [ ] Archive is not corrupted
- [ ] Files are readable
- [ ] Test random file restoration
- [ ] Verify backup size is reasonable

**Test Commands:**
```bash
# Test archive integrity
tar -tzf backup-YYYY-MM-DD.tar.gz > /dev/null && echo "OK" || echo "CORRUPTED"

# List contents
tar -tzf backup-YYYY-MM-DD.tar.gz | head -20

# Test extraction (to temp directory)
mkdir /tmp/test-restore
tar -xzf backup-YYYY-MM-DD.tar.gz -C /tmp/test-restore
ls -lh /tmp/test-restore/
rm -rf /tmp/test-restore
```

### Quarterly Full Restoration Test

**On a test VM or spare machine:**
1. Fresh macOS install
2. Restore from backup
3. Verify all apps work
4. Check all data accessible
5. Document any issues

---

## 🚨 Emergency Restoration

### Lost Everything - Full Recovery

**Priorities:**
1. **Bitwarden** - Restore passwords first
2. **SSH Keys** - Restore Git access
3. **Home Manager** - Restore development environment
4. **Emails** - Restore Thunderbird
5. **Project Context** - Restore Serena memories

**Step by step:**
```bash
# 1. Get backup from secure location
# Download from cloud or connect external drive

# 2. Extract
tar -xzf backup-YYYY-MM-DD.tar.gz

# 3. Restore Bitwarden (get passwords back)
cp backup-*/bitwarden/data.json ~/Library/Application\ Support/Bitwarden/
open -a Bitwarden

# 4. Restore SSH (get Git access)
cp -r backup-*/.ssh ~/
chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_*

# 5. Clone home-manager (if needed)
git clone git@github.com:yourusername/home-manager.git ~/repos/home-manager

# 6. Restore configs
cp -r backup-*/home-manager/* ~/repos/home-manager/
cp -r backup-*/.serena ~/repos/home-manager/

# 7. Install Nix and home-manager
# See installation guide

# 8. Restore Thunderbird
cp -r backup-*/thunderbird/Profiles/* ~/Library/Application\ Support/Thunderbird/Profiles/

# 9. Verify everything works
```

---

## 📝 Backup Checklist

### Before Backup
- [ ] Close Thunderbird
- [ ] Quit Bitwarden
- [ ] Ensure enough disk space (10GB+)
- [ ] Have 30 minutes available

### During Backup
- [ ] Run backup script
- [ ] Choose SSH backup option (if needed)
- [ ] Choose compression option
- [ ] Verify no errors in output

### After Backup
- [ ] Check backup size is reasonable
- [ ] Copy to external drive
- [ ] Copy to encrypted cloud storage
- [ ] Test archive integrity
- [ ] Document backup date
- [ ] Delete old backups (keep last 3-6)

### Security
- [ ] Delete unencrypted Bitwarden export
- [ ] Encrypt backup if storing on cloud
- [ ] Verify backup location is secure
- [ ] Don't leave backup on shared computer

---

## 🔧 Troubleshooting

### Backup Script Fails

**"Permission denied"**
```bash
chmod +x ~/repos/home-manager/scripts/backup-all.sh
```

**"No space left"**
```bash
# Check space
df -h

# Clean old backups
rm -rf ~/Backups/old-backup-*

# Use external drive
export BACKUP_DIR="/Volumes/ExternalDrive/Backups/$(date +%Y-%m-%d)"
./scripts/backup-all.sh
```

**Thunderbird profile not found**
```bash
# Find profiles manually
ls -la ~/Library/Application\ Support/Thunderbird/Profiles/

# Check if Thunderbird is installed
open -a Thunderbird || echo "Not installed"
```

### Restoration Issues

**Bitwarden won't unlock**
- Ensure you're using the correct master password
- Check data.json is not corrupted
- Try reinstalling Bitwarden app

**Thunderbird crashes after restore**
- Delete cache: `rm -rf ~/Library/Caches/Thunderbird/*`
- Reset profile: Thunderbird → Help → Troubleshooting Mode

**SSH keys don't work**
- Check permissions: `ls -l ~/.ssh/`
- Fix: `chmod 600 ~/.ssh/id_*`
- Test: `ssh -vvv git@github.com`

---

## 📅 Backup Schedule Recommendations

| Data Type | Frequency | Method |
|-----------|-----------|--------|
| Serena Memories | After each session | Manual or script |
| Home Manager | After config changes | Git + backup |
| Bitwarden | Weekly | Automated script |
| Thunderbird | Daily | Automated script |
| SSH Keys | After creation/changes | Manual |
| Full Backup | Weekly | Automated script |
| Test Restoration | Monthly | Manual |
| Off-site Copy | Weekly | Manual/sync |

---

**Last Updated:** 2026-02-14
**Tested On:** macOS Sequoia
