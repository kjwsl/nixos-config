#!/bin/bash
set -e

echo "=== Installing Node.js 22 ==="
curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash -
sudo yum install -y nodejs

echo "=== Verifying Node.js version ==="
node --version
npm --version

echo "=== Installing OpenClaw globally ==="
sudo npm install -g openclaw@latest

echo "=== Setting up OpenClaw daemon ==="
# Note: This will prompt for configuration
# For automated setup, we'll create a basic config

mkdir -p ~/.openclaw
cat > ~/.openclaw/config.json << 'EOF'
{
  "gateway": {
    "port": 3000,
    "host": "0.0.0.0"
  }
}
EOF

echo "=== Installing OpenClaw daemon ==="
openclaw onboard --install-daemon

echo ""
echo "=== OpenClaw Setup Complete! ==="
echo "Access at: http://15.164.228.202:3000"
echo ""
echo "Configuration: ~/.openclaw/config.json"
echo "Logs: journalctl -u openclaw -f"
echo ""
echo "Next steps:"
echo "1. Configure your API keys in ~/.openclaw/config.json"
echo "2. Restart: sudo systemctl restart openclaw"
