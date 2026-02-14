#!/bin/bash
# OpenClaw AWS Deployment Script
# Automates the entire setup process for reproducible deployments

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🦞 OpenClaw AWS Deployment Script${NC}"
echo ""

# Configuration
REGION="${AWS_REGION:-ap-northeast-2}"
INSTANCE_TYPE="${INSTANCE_TYPE:-t4g.micro}"
KEY_NAME="${KEY_NAME:-openclaw-key}"
SECURITY_GROUP_NAME="openclaw-sg"

# Step 1: Create SSH Key Pair
echo -e "${YELLOW}Step 1: Creating SSH key pair...${NC}"
if [ ! -f ~/.ssh/${KEY_NAME}.pem ]; then
    mise exec -- aws ec2 create-key-pair \
        --region ${REGION} \
        --key-name ${KEY_NAME} \
        --query 'KeyMaterial' \
        --output text > ~/.ssh/${KEY_NAME}.pem
    chmod 400 ~/.ssh/${KEY_NAME}.pem
    echo -e "${GREEN}✓ Key pair created: ~/.ssh/${KEY_NAME}.pem${NC}"
else
    echo -e "${GREEN}✓ Key pair already exists${NC}"
fi

# Step 2: Create Security Group
echo -e "${YELLOW}Step 2: Creating security group...${NC}"
SG_ID=$(mise exec -- aws ec2 describe-security-groups \
    --region ${REGION} \
    --filters "Name=group-name,Values=${SECURITY_GROUP_NAME}" \
    --query 'SecurityGroups[0].GroupId' \
    --output text 2>/dev/null)

if [ "$SG_ID" = "None" ] || [ -z "$SG_ID" ]; then
    SG_ID=$(mise exec -- aws ec2 create-security-group \
        --region ${REGION} \
        --group-name ${SECURITY_GROUP_NAME} \
        --description "OpenClaw security group" \
        --query 'GroupId' \
        --output text)

    # Allow SSH from current IP
    MY_IP=$(curl -s https://checkip.amazonaws.com)
    mise exec -- aws ec2 authorize-security-group-ingress \
        --region ${REGION} \
        --group-id ${SG_ID} \
        --protocol tcp --port 22 --cidr ${MY_IP}/32

    # Allow HTTP from anywhere
    mise exec -- aws ec2 authorize-security-group-ingress \
        --region ${REGION} \
        --group-id ${SG_ID} \
        --protocol tcp --port 80 --cidr 0.0.0.0/0

    echo -e "${GREEN}✓ Security group created: ${SG_ID}${NC}"
else
    echo -e "${GREEN}✓ Security group exists: ${SG_ID}${NC}"
fi

# Step 3: Get latest Amazon Linux 2023 ARM AMI
echo -e "${YELLOW}Step 3: Finding latest Amazon Linux 2023 ARM AMI...${NC}"
AMI_ID=$(mise exec -- aws ec2 describe-images \
    --region ${REGION} \
    --owners amazon \
    --filters "Name=name,Values=al2023-ami-2023.*-arm64" \
              "Name=state,Values=available" \
    --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
    --output text)
echo -e "${GREEN}✓ Using AMI: ${AMI_ID}${NC}"

# Step 4: Launch EC2 Instance
echo -e "${YELLOW}Step 4: Launching EC2 instance...${NC}"
INSTANCE_ID=$(mise exec -- aws ec2 run-instances \
    --region ${REGION} \
    --image-id ${AMI_ID} \
    --instance-type ${INSTANCE_TYPE} \
    --key-name ${KEY_NAME} \
    --security-group-ids ${SG_ID} \
    --block-device-mappings '[{"DeviceName":"/dev/xvda","Ebs":{"VolumeSize":20,"VolumeType":"gp3","DeleteOnTermination":true}}]' \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=openclaw-server}]' \
    --query 'Instances[0].InstanceId' \
    --output text)

echo -e "${GREEN}✓ Instance launched: ${INSTANCE_ID}${NC}"
echo -e "${YELLOW}Waiting for instance to be running...${NC}"

mise exec -- aws ec2 wait instance-running \
    --region ${REGION} \
    --instance-ids ${INSTANCE_ID}

# Get public IP
PUBLIC_IP=$(mise exec -- aws ec2 describe-instances \
    --region ${REGION} \
    --instance-ids ${INSTANCE_ID} \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

echo -e "${GREEN}✓ Instance running at: ${PUBLIC_IP}${NC}"
echo -e "${YELLOW}Waiting for SSH to be available (this may take 60 seconds)...${NC}"
sleep 60

# Step 5: Copy OpenClaw config from local machine
echo -e "${YELLOW}Step 5: Copying OpenClaw configuration...${NC}"
if [ -f ~/.openclaw/openclaw.json ]; then
    # Wait for SSH to be ready
    until ssh -i ~/.ssh/${KEY_NAME}.pem -o StrictHostKeyChecking=no ec2-user@${PUBLIC_IP} 'exit' 2>/dev/null; do
        echo -e "${YELLOW}Waiting for SSH...${NC}"
        sleep 5
    done

    ssh -i ~/.ssh/${KEY_NAME}.pem ec2-user@${PUBLIC_IP} 'mkdir -p ~/.openclaw'
    scp -i ~/.ssh/${KEY_NAME}.pem ~/.openclaw/openclaw.json ec2-user@${PUBLIC_IP}:~/.openclaw/

    if [ -d ~/.openclaw/credentials ]; then
        scp -i ~/.ssh/${KEY_NAME}.pem -r ~/.openclaw/credentials ec2-user@${PUBLIC_IP}:~/.openclaw/
    fi

    echo -e "${GREEN}✓ Configuration copied${NC}"
else
    echo -e "${RED}⚠ Warning: No local OpenClaw config found at ~/.openclaw/openclaw.json${NC}"
    echo -e "${YELLOW}You'll need to run 'openclaw setup' on the instance${NC}"
fi

# Step 6: Deploy OpenClaw
echo -e "${YELLOW}Step 6: Deploying OpenClaw...${NC}"
ssh -i ~/.ssh/${KEY_NAME}.pem ec2-user@${PUBLIC_IP} 'bash -s' << 'ENDSSH'
set -e

echo "Installing Node.js 22..."
curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash -
sudo yum install -y nodejs git

echo "Installing OpenClaw..."
sudo npm install -g openclaw@latest

echo "Creating swap space..."
sudo dd if=/dev/zero of=/swapfile bs=1M count=2048 status=progress
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

echo "Creating systemd service..."
sudo tee /etc/systemd/system/openclaw.service > /dev/null << 'EOF'
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

echo "Installing and configuring Nginx..."
sudo yum install -y nginx

sudo tee /etc/nginx/conf.d/openclaw.conf > /dev/null << 'EOF'
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

echo "Starting services..."
sudo systemctl daemon-reload
sudo systemctl enable --now openclaw
sudo systemctl enable --now nginx

echo "Deployment complete!"
ENDSSH

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ OpenClaw Deployment Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "🌐 Access URL:     ${GREEN}http://${PUBLIC_IP}${NC}"
echo -e "🔑 SSH Command:    ${YELLOW}ssh -i ~/.ssh/${KEY_NAME}.pem ec2-user@${PUBLIC_IP}${NC}"
echo -e "📦 Instance ID:    ${INSTANCE_ID}"
echo -e "🔒 Security Group: ${SG_ID}"
echo -e "🌍 Region:         ${REGION}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Open http://${PUBLIC_IP} in your browser"
echo -e "2. Test the OpenClaw interface"
echo -e "3. Check logs: ${YELLOW}ssh -i ~/.ssh/${KEY_NAME}.pem ec2-user@${PUBLIC_IP} 'sudo journalctl -u openclaw -f'${NC}"
echo ""

# Save deployment info
cat > openclaw-deployment.env << EOF
OPENCLAW_INSTANCE_ID=${INSTANCE_ID}
OPENCLAW_PUBLIC_IP=${PUBLIC_IP}
OPENCLAW_REGION=${REGION}
OPENCLAW_SECURITY_GROUP=${SG_ID}
OPENCLAW_KEY_NAME=${KEY_NAME}
OPENCLAW_ACCESS_URL=http://${PUBLIC_IP}
EOF

echo -e "${GREEN}💾 Deployment info saved to: openclaw-deployment.env${NC}"
