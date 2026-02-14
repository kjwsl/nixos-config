# OpenClaw 24/7 Deployment on AWS Free Tier

Complete guide to deploy OpenClaw AI assistant on Amazon EC2 free tier for 24/7 operation.

## What is OpenClaw?

OpenClaw (formerly Moltbot/Clawdbot) is a personal AI assistant that:
- Runs 24/7 on your own infrastructure
- Integrates with WhatsApp, Telegram, Slack, Discord
- Automates tasks, manages workflows, books appointments
- Provides AI assistance across multiple platforms

**Official**: https://openclaw.ai/ | **GitHub**: https://github.com/openclaw/openclaw

## AWS Free Tier Specifications

**EC2 Instance**: t2.micro or t3.micro
- **CPU**: 1 vCPU
- **RAM**: 1 GB
- **Free Tier**: 750 hours/month (enough for 24/7)
- **Storage**: 30 GB EBS (free tier)
- **Data Transfer**: 15 GB/month out (free tier)

## Prerequisites

1. AWS Account with free tier eligibility
2. SSH key pair for EC2 access
3. OpenClaw API keys (Claude, OpenAI, etc.)
4. Domain name (optional, for HTTPS)

## Security Warning ⚠️

**OpenClaw ships with permissive defaults designed for local development.**
Running it on a VPS without hardening is dangerous. Use [SaferClaw](https://github.com/AbraKDobrey/SaferClaw) for production deployment.

## Deployment Options

### Option 1: Quick Deploy (Docker - Recommended)

#### Step 1: Launch EC2 Instance

```bash
# Launch instance
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \  # Amazon Linux 2023
  --instance-type t2.micro \
  --key-name your-key-name \
  --security-group-ids sg-xxxxxxxx \
  --subnet-id subnet-xxxxxxxx \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=openclaw-server}]'
```

#### Step 2: Configure Security Group

Allow these ports:
- **SSH**: 22 (your IP only)
- **OpenClaw**: 3000 (or your custom port)
- **Optional HTTPS**: 443

```bash
# Create security group
aws ec2 create-security-group \
  --group-name openclaw-sg \
  --description "Security group for OpenClaw"

# Allow SSH from your IP
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxxxxx \
  --protocol tcp \
  --port 22 \
  --cidr YOUR_IP/32

# Allow OpenClaw port
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxxxxx \
  --protocol tcp \
  --port 3000 \
  --cidr 0.0.0.0/0
```

#### Step 3: SSH into Instance

```bash
ssh -i your-key.pem ec2-user@your-instance-ip
```

#### Step 4: Install Docker

```bash
# Update system
sudo yum update -y

# Install Docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Logout and login for group changes
exit
# ssh back in
```

#### Step 5: Deploy OpenClaw with Docker

```bash
# Create directory
mkdir -p ~/openclaw
cd ~/openclaw

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  openclaw:
    image: openclaw/openclaw:latest
    container_name: openclaw
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      # API Keys (use AWS Secrets Manager in production)
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - OPENAI_API_KEY=${OPENAI_API_KEY}

      # Security settings
      - NODE_ENV=production
      - ENABLE_AUTH=true
      - SESSION_SECRET=${SESSION_SECRET}

      # Integrations (optional)
      - TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}
      - SLACK_BOT_TOKEN=${SLACK_BOT_TOKEN}
    volumes:
      - ./data:/app/data
      - ./logs:/app/logs
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
EOF

# Create .env file
cat > .env << 'EOF'
# AI Provider Keys
ANTHROPIC_API_KEY=your_anthropic_key_here
OPENAI_API_KEY=your_openai_key_here

# Security
SESSION_SECRET=generate_random_string_here

# Optional Integrations
# TELEGRAM_BOT_TOKEN=your_telegram_token
# SLACK_BOT_TOKEN=your_slack_token
EOF

# Generate secure session secret
SESSION_SECRET=$(openssl rand -hex 32)
sed -i "s/generate_random_string_here/$SESSION_SECRET/" .env

echo "⚠️  Edit .env and add your API keys!"
```

#### Step 6: Start OpenClaw

```bash
# Start service
docker-compose up -d

# Check logs
docker-compose logs -f

# Check status
docker-compose ps
```

### Option 2: NixOS Deployment (Advanced)

If you prefer NixOS on EC2:

```nix
# openclaw-service.nix
{ config, pkgs, ... }:

{
  # OpenClaw systemd service
  systemd.services.openclaw = {
    description = "OpenClaw AI Assistant";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      User = "openclaw";
      Group = "openclaw";
      Restart = "always";
      RestartSec = "10s";

      # Security hardening
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;

      # Environment
      EnvironmentFile = "/etc/openclaw/secrets.env";
      WorkingDirectory = "/var/lib/openclaw";

      # Start command
      ExecStart = "${pkgs.docker}/bin/docker-compose -f /etc/openclaw/docker-compose.yml up";
    };
  };

  # User for service
  users.users.openclaw = {
    isSystemUser = true;
    group = "openclaw";
    home = "/var/lib/openclaw";
    createHome = true;
  };

  users.groups.openclaw = {};

  # Firewall
  networking.firewall.allowedTCPPorts = [ 3000 ];
}
```

### Option 3: SaferClaw (Production-Ready)

For production deployment with security hardening:

```bash
# Clone SaferClaw
git clone https://github.com/AbraKDobrey/SaferClaw.git
cd SaferClaw

# Follow their hardened setup
./deploy.sh --platform aws --instance-type t2.micro
```

## Post-Deployment Configuration

### 1. Set Up Systemd Auto-Restart

```bash
# Create systemd service
sudo tee /etc/systemd/system/openclaw.service << EOF
[Unit]
Description=OpenClaw AI Assistant
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ec2-user/openclaw
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
User=ec2-user

[Install]
WantedBy=multi-user.target
EOF

# Enable and start
sudo systemctl enable openclaw
sudo systemctl start openclaw

# Check status
sudo systemctl status openclaw
```

### 2. Set Up Monitoring

```bash
# Install CloudWatch agent (optional)
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
sudo rpm -U ./amazon-cloudwatch-agent.rpm

# Basic health check script
cat > ~/check-openclaw.sh << 'EOF'
#!/bin/bash
if ! curl -f http://localhost:3000/health > /dev/null 2>&1; then
  echo "OpenClaw is down! Restarting..."
  cd ~/openclaw && docker-compose restart
fi
EOF

chmod +x ~/check-openclaw.sh

# Add to crontab (check every 5 minutes)
(crontab -l 2>/dev/null; echo "*/5 * * * * ~/check-openclaw.sh") | crontab -
```

### 3. Set Up Backups

```bash
# Backup script
cat > ~/backup-openclaw.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=~/openclaw-backups
mkdir -p $BACKUP_DIR

# Backup data
tar -czf $BACKUP_DIR/openclaw-data-$DATE.tar.gz -C ~/openclaw data/

# Keep only last 7 backups
ls -t $BACKUP_DIR/openclaw-data-*.tar.gz | tail -n +8 | xargs -r rm

# Optional: sync to S3
# aws s3 sync $BACKUP_DIR s3://your-bucket/openclaw-backups/
EOF

chmod +x ~/backup-openclaw.sh

# Daily backup at 2 AM
(crontab -l 2>/dev/null; echo "0 2 * * * ~/backup-openclaw.sh") | crontab -
```

### 4. Set Up HTTPS (Optional)

```bash
# Install Caddy (automatic HTTPS)
sudo yum install -y yum-plugin-copr
sudo yum copr enable @caddy/caddy -y
sudo yum install -y caddy

# Create Caddyfile
sudo tee /etc/caddy/Caddyfile << EOF
your-domain.com {
    reverse_proxy localhost:3000
}
EOF

# Start Caddy
sudo systemctl enable caddy
sudo systemctl start caddy
```

## Cost Optimization

### Staying Within Free Tier

1. **Instance**: t2.micro (1 GB RAM) - 750 hrs/month free
2. **Storage**: Max 30 GB EBS - free tier
3. **Data Transfer**: Keep under 15 GB/month outbound
4. **Snapshots**: Delete old AMI snapshots regularly

### Monitoring Costs

```bash
# Set up billing alert in AWS Console
# CloudWatch → Billing → Create Alarm
# Alert when charges > $1
```

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker-compose logs openclaw

# Check Docker status
sudo systemctl status docker

# Restart everything
docker-compose down && docker-compose up -d
```

### Out of Memory

```bash
# Add swap (EC2 t2.micro only has 1GB RAM)
sudo dd if=/dev/zero of=/swapfile bs=1M count=2048
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### High CPU Usage

```bash
# Limit Docker container resources
# Add to docker-compose.yml:
#   deploy:
#     resources:
#       limits:
#         cpus: '0.5'
#         memory: 512M
```

## Maintenance

### Update OpenClaw

```bash
cd ~/openclaw
docker-compose pull
docker-compose up -d
```

### View Logs

```bash
# Live logs
docker-compose logs -f

# Last 100 lines
docker-compose logs --tail=100

# Specific service
docker-compose logs openclaw
```

### Restart Service

```bash
# Graceful restart
docker-compose restart

# Full restart
docker-compose down && docker-compose up -d
```

## Security Checklist

- [ ] Use AWS Secrets Manager for API keys (not .env files)
- [ ] Restrict SSH to your IP only
- [ ] Enable CloudWatch logging
- [ ] Set up automatic security updates
- [ ] Use HTTPS with valid certificate
- [ ] Enable AWS GuardDuty for threat detection
- [ ] Regular backups to S3
- [ ] Review CloudTrail logs monthly
- [ ] Use SaferClaw deployment template
- [ ] Enable MFA on AWS account

## Alternative: One-Click Deployment

If AWS setup is too complex, consider:

1. **Contabo**: One-click OpenClaw deployment ($6/month)
   - https://contabo.com/blog/what-is-openclaw-self-hosted-ai-agent-guide/

2. **Hostinger VPS**: Docker template for OpenClaw
   - https://www.hostinger.com/vps/docker/openclaw

3. **DigitalOcean**: OpenClaw droplet (1-click)
   - Check marketplace for OpenClaw image

## Resources

- OpenClaw Official: https://openclaw.ai/
- GitHub: https://github.com/openclaw/openclaw
- SaferClaw (hardened): https://github.com/AbraKDobrey/SaferClaw
- AWS Free Tier: https://aws.amazon.com/free/
- VPS Deployment Guide: https://www.ai.cc/blogs/openclaw-vps-guide-run-ai-agent-24-7-budget/

## Next Steps

1. Deploy OpenClaw following this guide
2. Configure your AI provider API keys
3. Set up messaging platform integrations
4. Configure systemd for auto-restart
5. Set up monitoring and backups
6. Secure with HTTPS
7. Test 24/7 operation

**Estimated Monthly Cost**: $0-$5 (free tier) or $5-$10 (after free tier expires)
