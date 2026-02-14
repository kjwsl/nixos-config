#!/bin/bash
set -e

# Install Node.js 22
curl -fsSL https://rpm.nodesource.com/setup_22.x | bash -
yum install -y nodejs git

# Install OpenClaw
npm install -g openclaw@latest

# Create swap space
dd if=/dev/zero of=/swapfile bs=1M count=2048 status=progress
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Create OpenClaw config directory
mkdir -p /home/ec2-user/.openclaw
chown -R ec2-user:ec2-user /home/ec2-user/.openclaw

# Write OpenClaw config (passed from Terraform)
cat > /home/ec2-user/.openclaw/openclaw.json << 'EOF'
${openclaw_config}
EOF
chown ec2-user:ec2-user /home/ec2-user/.openclaw/openclaw.json

# Create systemd service
cat > /etc/systemd/system/openclaw.service << 'EOF'
[Unit]
Description=OpenClaw Gateway
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user
Environment="NODE_ENV=production"
Environment="NODE_OPTIONS=--max-old-space-size=768"
Environment="OPENCLAW_CONFIG_PATH=/home/ec2-user/.openclaw/openclaw.json"
ExecStart=/usr/bin/openclaw gateway --port 3000 --allow-unconfigured
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Install and configure Nginx
yum install -y nginx

cat > /etc/nginx/conf.d/openclaw.conf << 'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 86400;
    }
}
EOF

# Start services
systemctl daemon-reload
systemctl enable --now openclaw
systemctl enable --now nginx

# Log completion
echo "OpenClaw deployment completed at $(date)" >> /var/log/openclaw-setup.log
