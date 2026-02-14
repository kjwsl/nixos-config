# OpenClaw AWS Deployment Summary

## 🎯 Deployment Details

**Instance Information:**
- **Instance ID:** i-0942512f150ad90b1
- **Type:** t4g.micro (ARM64, 1GB RAM, 2 vCPUs)
- **Public IP:** 15.164.228.202
- **Region:** ap-northeast-2 (Seoul)
- **Access URL:** http://15.164.228.202

**SSH Access:**
```bash
ssh -i ~/.ssh/openclaw-key.pem ec2-user@15.164.228.202
```

## 🏗️ Architecture

```
Internet → Port 80 → Nginx (reverse proxy) → Port 3000 → OpenClaw Gateway
```

**Services Running:**
- `openclaw.service` - OpenClaw gateway (localhost:3000)
- `nginx.service` - Reverse proxy (0.0.0.0:80)

## ⚙️ Configuration

**OpenClaw Config:** `~/.openclaw/openclaw.json`
- **Model:** Google Gemini 3 Pro (via OAuth from your Mac)
- **Gateway Port:** 3000 (localhost only)
- **Memory Limit:** 768MB heap (NODE_OPTIONS=--max-old-space-size=768)
- **Authentication:** Google Gemini CLI OAuth

**Nginx Config:** `/etc/nginx/conf.d/openclaw.conf`
- Forwards HTTP traffic to OpenClaw
- WebSocket support enabled
- Long read timeout for persistent connections

**Systemd Service:** `/etc/systemd/system/openclaw.service`
- Auto-starts on boot
- Restarts on failure
- Reduced memory footprint for t4g.micro

## 🔧 Management Commands

### Check Service Status
```bash
ssh -i ~/.ssh/openclaw-key.pem ec2-user@15.164.228.202 \
  'sudo systemctl status openclaw nginx'
```

### View Logs
```bash
# OpenClaw logs
ssh -i ~/.ssh/openclaw-key.pem ec2-user@15.164.228.202 \
  'sudo journalctl -u openclaw -f'

# Nginx logs
ssh -i ~/.ssh/openclaw-key.pem ec2-user@15.164.228.202 \
  'sudo journalctl -u nginx -f'
```

### Restart Services
```bash
ssh -i ~/.ssh/openclaw-key.pem ec2-user@15.164.228.202 \
  'sudo systemctl restart openclaw nginx'
```

### Stop Services
```bash
ssh -i ~/.ssh/openclaw-key.pem ec2-user@15.164.228.202 \
  'sudo systemctl stop openclaw nginx'
```

## 📊 Resource Usage

**Memory Optimization:**
- 2GB swap space configured (helps with memory pressure)
- Node.js heap limited to 768MB
- OpenClaw running with minimal plugins (~380MB memory)

**Monitoring:**
```bash
# Check memory usage
ssh -i ~/.ssh/openclaw-key.pem ec2-user@15.164.228.202 'free -h'

# Check OpenClaw memory
ssh -i ~/.ssh/openclaw-key.pem ec2-user@15.164.228.202 \
  'sudo systemctl status openclaw | grep Memory'
```

## 🔒 Security

**Firewall Rules:**
- Port 22 (SSH): Your IP only
- Port 80 (HTTP): Open to internet (0.0.0.0/0)
- Port 3000: Not exposed (localhost only)

**Security Group:** sg-01a0f1ab2c4c2a621

**Recommendations:**
- Consider adding HTTPS with Let's Encrypt
- Restrict port 80 to trusted IPs if not public
- Monitor logs for unusual activity

## 💰 Cost Optimization

**AWS Free Tier Eligible:**
- t4g.micro: 750 hours/month free
- 30GB EBS storage free
- Minimal data transfer costs

**Monthly Cost Estimate:**
- Compute: $0 (free tier)
- Storage: $0 (under 30GB)
- Data Transfer: ~$1-2/month
- **Total:** $1-2/month (after free tier expires)

## 🚀 Next Steps

1. **Test the Web Interface:**
   - Open http://15.164.228.202 in your browser
   - Verify OAuth authentication works
   - Test AI conversations

2. **Optional Enhancements:**
   - Add HTTPS with Certbot/Let's Encrypt
   - Set up CloudWatch monitoring
   - Configure automatic backups
   - Add domain name

3. **Maintenance:**
   - Monitor memory usage regularly
   - Check logs weekly
   - Update OpenClaw monthly: `npm update -g openclaw`

## 🐛 Troubleshooting

### OpenClaw Won't Start
```bash
# Check logs for errors
ssh -i ~/.ssh/openclaw-key.pem ec2-user@15.164.228.202 \
  'sudo journalctl -u openclaw --no-pager -n 50'

# Check memory usage
ssh -i ~/.ssh/openclaw-key.pem ec2-user@15.164.228.202 'free -h'

# Restart service
ssh -i ~/.ssh/openclaw-key.pem ec2-user@15.164.228.202 \
  'sudo systemctl restart openclaw'
```

### Web Interface Not Accessible
```bash
# Check nginx status
ssh -i ~/.ssh/openclaw-key.pem ec2-user@15.164.228.202 \
  'sudo systemctl status nginx'

# Test local access
ssh -i ~/.ssh/openclaw-key.pem ec2-user@15.164.228.202 \
  'curl -I http://localhost:3000'
```

### Out of Memory Errors
```bash
# Check swap
ssh -i ~/.ssh/openclaw-key.pem ec2-user@15.164.228.202 'swapon --show'

# Restart with cleared cache
ssh -i ~/.ssh/openclaw-key.pem ec2-user@15.164.228.202 \
  'rm -rf ~/.openclaw/cache/* && sudo systemctl restart openclaw'
```

## 📝 Files Created

- `~/.openclaw/openclaw.json` - Main configuration (copied from Mac)
- `~/.openclaw/credentials/` - OAuth credentials
- `/etc/systemd/system/openclaw.service` - Systemd service file
- `/etc/nginx/conf.d/openclaw.conf` - Nginx reverse proxy config
- `/swapfile` - 2GB swap space

## 🎓 What We Did

1. **Created EC2 instance** with ARM architecture (t4g.micro)
2. **Installed Node.js 22** via NodeSource repository
3. **Installed OpenClaw** globally via npm
4. **Added swap space** to handle memory pressure
5. **Copied OAuth config** from your Mac
6. **Configured systemd service** with memory limits
7. **Set up Nginx** as reverse proxy for external access
8. **Opened firewall ports** in security group

## 🌟 Features Available

- ✅ AI conversations with Google Gemini 3 Pro
- ✅ Web-based chat interface
- ✅ 24/7 availability
- ✅ OAuth authentication (no API keys needed)
- ✅ Auto-restart on failure
- ✅ Memory-optimized for free tier

---

**Setup Date:** 2026-02-14
**OpenClaw Version:** 2026.2.13
**Node.js Version:** 22.x
