#!/bin/bash
# OpenClaw AWS Teardown Script
# Safely removes all OpenClaw infrastructure

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}🧹 OpenClaw AWS Teardown Script${NC}"
echo ""

# Load deployment info if available
if [ -f openclaw-deployment.env ]; then
    source openclaw-deployment.env
    echo -e "${GREEN}✓ Loaded deployment info from openclaw-deployment.env${NC}"
else
    echo -e "${YELLOW}No openclaw-deployment.env found. Please provide details:${NC}"
    read -p "Instance ID: " OPENCLAW_INSTANCE_ID
    read -p "Region [ap-northeast-2]: " OPENCLAW_REGION
    OPENCLAW_REGION=${OPENCLAW_REGION:-ap-northeast-2}
fi

echo ""
echo -e "${YELLOW}About to delete:${NC}"
echo -e "  Instance ID: ${OPENCLAW_INSTANCE_ID}"
echo -e "  Region: ${OPENCLAW_REGION}"
echo ""
read -p "Are you sure? (type 'yes' to confirm): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "${RED}Aborted.${NC}"
    exit 1
fi

# Step 1: Terminate instance
echo -e "${YELLOW}Terminating EC2 instance...${NC}"
mise exec -- aws ec2 terminate-instances \
    --region ${OPENCLAW_REGION} \
    --instance-ids ${OPENCLAW_INSTANCE_ID}

echo -e "${GREEN}✓ Instance termination initiated${NC}"
echo -e "${YELLOW}Waiting for instance to terminate...${NC}"

mise exec -- aws ec2 wait instance-terminated \
    --region ${OPENCLAW_REGION} \
    --instance-ids ${OPENCLAW_INSTANCE_ID}

echo -e "${GREEN}✓ Instance terminated${NC}"

# Step 2: Clean up local files (optional)
echo ""
read -p "Remove local deployment files? (y/n): " REMOVE_LOCAL
if [ "$REMOVE_LOCAL" = "y" ]; then
    rm -f openclaw-deployment.env
    echo -e "${GREEN}✓ Local deployment files removed${NC}"
fi

echo ""
echo -e "${YELLOW}Note: Security group and key pair were preserved.${NC}"
echo -e "${YELLOW}To remove them manually:${NC}"
echo -e "  Security Group: mise exec -- aws ec2 delete-security-group --region ${OPENCLAW_REGION} --group-id ${OPENCLAW_SECURITY_GROUP}"
echo -e "  Key Pair: mise exec -- aws ec2 delete-key-pair --region ${OPENCLAW_REGION} --key-name ${OPENCLAW_KEY_NAME}"
echo -e "  Local Key: rm ~/.ssh/${OPENCLAW_KEY_NAME}.pem"
echo ""
echo -e "${GREEN}✅ Teardown complete!${NC}"
