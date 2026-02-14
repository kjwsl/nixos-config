# Email Backup Notes

## Current Setup

You have **two email clients**:

### 1. Thunderbird (Primary)
- **Active Profile:** `garsxlha.default-release` (929MB)
- **Old Profile:** `ahcxhtxz.default` (4KB - inactive)
- **Location:** `~/Library/Thunderbird/Profiles/`
- **Type:** Full local email storage + IMAP sync
- **Backup Priority:** HIGH (929MB of emails)

### 2. Himalaya (CLI)
- **Account:** kjwdev01@gmail.com
- **Config:** `~/Library/Application Support/himalaya/config.toml`
- **Type:** IMAP-only (emails stay on server)
- **Backup Priority:** LOW (just config, no local emails)
- **Password:** Stored in macOS Keychain

## Backup Strategy

### Thunderbird
**Full backup needed:** YES - 929MB of local data

**What to backup:**
- Entire profile directory (emails, contacts, calendar)
- profiles.ini (profile configuration)

**Backup command:**
```bash
# Included in backup-all.sh automatically
./scripts/backup-all.sh
```

**Manual backup:**
```bash
BACKUP_DIR=~/Backups/thunderbird-$(date +%Y%m%d)
mkdir -p "$BACKUP_DIR"

# Backup profiles
cp -r ~/Library/Thunderbird/Profiles "$BACKUP_DIR/"

# Backup configuration
cp ~/Library/Thunderbird/profiles.ini "$BACKUP_DIR/"

# Create archive
tar -czf ~/Backups/thunderbird-$(date +%Y%m%d).tar.gz -C ~/Backups thunderbird-$(date +%Y%m%d)
```

### Himalaya
**Full backup needed:** NO - emails on Gmail server

**What to backup:**
- config.toml (4KB)
- Password is in macOS Keychain (backed up separately)

**Backup command:**
```bash
# Included in backup-all.sh automatically
# Or manual:
cp ~/Library/Application\ Support/himalaya/config.toml ~/Backups/
```

## Password Management

### Thunderbird
Passwords stored in:
- Thunderbird's internal password manager
- Backed up within the profile directory automatically

### Himalaya
Password retrieved via macOS Keychain:
```bash
# Current setup uses this command:
security find-generic-password -a kjwdev01@gmail.com -s himalaya -w
```

**Keychain backup:**
```bash
# Export keychain item (for migration to new Mac)
security find-generic-password -a kjwdev01@gmail.com -s himalaya -g

# To restore on new Mac:
security add-generic-password -a kjwdev01@gmail.com -s himalaya -w
# (will prompt for password)
```

## Restoration Guide

### Thunderbird Full Restore
```bash
# 1. Install Thunderbird
brew install --cask thunderbird

# 2. Restore profiles
cp -r backup/Thunderbird/Profiles/* ~/Library/Thunderbird/Profiles/
cp backup/Thunderbird/profiles.ini ~/Library/Thunderbird/

# 3. Launch and verify
open -a Thunderbird
```

### Himalaya Restore
```bash
# 1. Install Himalaya
brew install himalaya

# 2. Restore config
mkdir -p ~/Library/Application\ Support/himalaya
cp backup/himalaya/config.toml ~/Library/Application\ Support/himalaya/

# 3. Add password to Keychain
security add-generic-password -a kjwdev01@gmail.com -s himalaya -w
# Enter your Gmail app password when prompted

# 4. Test
himalaya accounts list
himalaya list
```

## Gmail App Password

Himalaya uses Gmail App Password, not your regular password.

**If you need to regenerate:**
1. Go to Google Account → Security → 2-Step Verification
2. Scroll down to "App passwords"
3. Create new app password for "Himalaya"
4. Store in Keychain:
   ```bash
   security add-generic-password -a kjwdev01@gmail.com -s himalaya -w
   ```

## Migration Notes

### Moving to New Mac

**Thunderbird:**
1. Backup on old Mac: `./scripts/backup-all.sh`
2. Copy archive to new Mac
3. Restore profiles to `~/Library/Thunderbird/Profiles/`
4. Launch Thunderbird - everything works

**Himalaya:**
1. Copy config.toml to new Mac
2. Add password to Keychain on new Mac
3. Done - emails sync from server

### Cloud Sync Consideration

**Thunderbird:**
- ❌ Do NOT sync via Dropbox/iCloud (corruption risk)
- ✅ Use backup script and external drive
- ✅ Or use Thunderbird's built-in sync features

**Himalaya:**
- ✅ Config file is safe to sync
- ⚠️ But password needs manual setup on each machine

## Backup Size Summary

| Component | Size | Backup Needed |
|-----------|------|---------------|
| Thunderbird (active profile) | 929MB | Yes |
| Thunderbird (old profile) | 4KB | Optional |
| Himalaya config | 4KB | Yes |
| Himalaya emails | 0 (on server) | No |

**Total email backup size: ~930MB**

## Testing Your Backup

### Test Thunderbird Backup
```bash
# 1. Create test backup
./scripts/backup-all.sh

# 2. Check backup contents
tar -tzf ~/Backups/backup-*.tar.gz | grep Thunderbird

# 3. Verify profile is included
tar -tzf ~/Backups/backup-*.tar.gz | grep "garsxlha.default-release" | head
```

### Test Himalaya Backup
```bash
# 1. Verify config is backed up
tar -tzf ~/Backups/backup-*.tar.gz | grep himalaya/config.toml

# 2. Test account access (doesn't need backup to work)
himalaya accounts list
himalaya list
```

## Emergency: Lost All Emails

### If Thunderbird Profile Corrupted
1. Emails are on IMAP server (if you use IMAP)
2. Re-sync from server:
   - Delete corrupted profile
   - Set up account again
   - Thunderbird will download from server

### If Gmail Account Locked/Lost
1. Thunderbird has local copies (if IMAP cache exists)
2. Even without server access, emails are in profile
3. Can export as .mbox files for migration

## Automated Backup Recommendations

```bash
# Add to crontab for daily Thunderbird backups
# Edit: crontab -e
0 2 * * * /Users/ray/repos/home-manager/scripts/backup-all.sh --auto >> /tmp/backup.log 2>&1
```

**Rotate old backups:**
```bash
# Keep last 7 days
find ~/Backups -name "backup-*.tar.gz" -mtime +7 -delete
```
