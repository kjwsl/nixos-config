#!/bin/bash
set -e

echo "=== Installing Docker ==="
sudo yum update -y
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

echo "=== Installing Docker Compose ==="
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "=== Creating OpenClaw directory ==="
mkdir -p ~/openclaw
cd ~/openclaw

echo "=== Creating docker-compose.yml ==="
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
      - NODE_ENV=production
      - ENABLE_AUTH=true
    volumes:
      - ./data:/app/data
      - ./logs:/app/logs
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
EOF

echo "=== Creating .env file ==="
cat > .env << 'EOF'
# Add your API keys here
ANTHROPIC_API_KEY=
OPENAI_API_KEY=
SESSION_SECRET=$(openssl rand -hex 32)
EOF

echo "=== Starting OpenClaw ==="
docker-compose up -d

echo ""
echo "=== OpenClaw Deployed! ==="
echo "Access at: http://15.164.228.202:3000"
echo ""
echo "Next steps:"
echo "1. Edit ~/openclaw/.env and add your API keys"
echo "2. Restart: docker-compose restart"
echo "3. Check logs: docker-compose logs -f"
