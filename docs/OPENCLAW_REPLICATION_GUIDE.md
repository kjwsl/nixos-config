# OpenClaw Deployment Replication Guide

Complete guide for recreating the OpenClaw AWS deployment anytime.

## 🎯 Three Ways to Deploy

### 1. Automated Bash Script (Fastest)

**Best for:** Quick deployments, testing, one-off instances

```bash
cd ~/repos/home-manager
./scripts/deploy-openclaw.sh
```

**What it does:**
- ✅ Creates SSH key pair
- ✅ Creates security group
- ✅ Launches EC2 instance
- ✅ Copies your local OpenClaw config
- ✅ Installs Node.js, OpenClaw, Nginx
- ✅ Configures systemd services
- ✅ Saves deployment info to `openclaw-deployment.env`

**Time:** ~5 minutes

**Cleanup:**
```bash
./scripts/teardown-openclaw.sh
```

---

### 2. Terraform (Most Reliable)

**Best for:** Production, teams, multiple environments, infrastructure-as-code

```bash
cd ~/repos/home-manager/terraform/openclaw

# First time setup
terraform init

# Deploy
terraform plan   # Review changes
terraform apply  # Deploy

# Access outputs
terraform output access_url
terraform output ssh_command

# Cleanup
terraform destroy
```

**Advantages:**
- State tracking and drift detection
- Declarative configuration
- Team collaboration
- Multiple environments (dev/staging/prod)
- Automated dependency management

**Time:** ~7 minutes (includes review)

---

### 3. Manual Steps (Full Control)

**Best for:** Learning, custom setups, troubleshooting

Follow the detailed guide in [`OPENCLAW_AWS_SETUP.md`](./OPENCLAW_AWS_SETUP.md)

---

## 📋 Prerequisites Checklist

### Required for All Methods

- [ ] AWS account with free tier available
- [ ] AWS credentials configured (via `mise` or environment)
- [ ] Local OpenClaw configuration at `~/.openclaw/openclaw.json`
- [ ] OpenClaw credentials at `~/.openclaw/credentials/` (if using OAuth)
- [ ] `mise` installed with AWS CLI configured

### Check Prerequisites

```bash
# Verify mise has AWS CLI
mise exec -- aws --version

# Verify AWS credentials
mise exec -- aws sts get-caller-identity

# Verify OpenClaw config exists
ls -la ~/.openclaw/openclaw.json
```

---

## 🚀 Quick Deployment Comparison

| Method | Time | Idempotent | State Tracking | Best For |
|--------|------|------------|----------------|----------|
| **Bash Script** | 5 min | No | Manual | Quick testing |
| **Terraform** | 7 min | Yes | Automatic | Production |
| **Manual** | 15 min | No | None | Learning |

---

## 🔧 Configuration Options

### Environment Variables

Both scripts support customization via environment variables:

```bash
# Change region
export AWS_REGION=us-east-1

# Use larger instance
export INSTANCE_TYPE=t4g.small

# Custom key name
export KEY_NAME=my-openclaw-key

# Deploy with custom settings
./scripts/deploy-openclaw.sh
```

### Terraform Variables

Create `terraform/openclaw/terraform.tfvars`:

```hcl
aws_region           = "us-west-2"
instance_type        = "t4g.small"
key_name             = "production-openclaw"
public_key_path      = "~/.ssh/production-openclaw.pub"
openclaw_config_path = "~/.openclaw/openclaw.json"
```

---

## 📝 Deployment Workflows

### Development Workflow

```bash
# 1. Test with bash script
./scripts/deploy-openclaw.sh

# 2. Test the deployment
curl http://<PUBLIC_IP>

# 3. Teardown
./scripts/teardown-openclaw.sh
```

### Production Workflow

```bash
# 1. Create production config
cp ~/.openclaw/openclaw.json ~/.openclaw/production.json
# Edit production.json for production settings

# 2. Deploy with Terraform
cd terraform/openclaw
terraform workspace new production
terraform apply -var="openclaw_config_path=~/.openclaw/production.json"

# 3. Save state for team
git add terraform.tfstate
git commit -m "Update production Terraform state"
```

### Multi-Region Workflow

```bash
# Deploy to multiple regions
for region in us-east-1 us-west-2 ap-northeast-2; do
  export AWS_REGION=$region
  ./scripts/deploy-openclaw.sh
done
```

---

## 🔄 Update Existing Deployment

### Update OpenClaw Version

```bash
# SSH to instance
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<PUBLIC_IP>

# Update OpenClaw
sudo npm update -g openclaw

# Restart service
sudo systemctl restart openclaw
```

### Update Configuration

```bash
# Copy new config
scp -i ~/.ssh/openclaw-key.pem \
  ~/.openclaw/openclaw.json \
  ec2-user@<PUBLIC_IP>:~/.openclaw/

# Restart OpenClaw
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<PUBLIC_IP> \
  'sudo systemctl restart openclaw'
```

---

## 💾 Backup and Restore

### Backup Current Deployment

```bash
# Backup OpenClaw config
scp -i ~/.ssh/openclaw-key.pem \
  ec2-user@<PUBLIC_IP>:~/.openclaw/openclaw.json \
  ./backup-openclaw-config.json

# Backup credentials
scp -i ~/.ssh/openclaw-key.pem -r \
  ec2-user@<PUBLIC_IP>:~/.openclaw/credentials \
  ./backup-credentials/

# Save instance metadata
mise exec -- aws ec2 describe-instances \
  --instance-ids <INSTANCE_ID> \
  --region ap-northeast-2 > backup-instance-metadata.json
```

### Restore to New Instance

```bash
# Copy files to new instance after deployment
scp -i ~/.ssh/openclaw-key.pem \
  ./backup-openclaw-config.json \
  ec2-user@<NEW_PUBLIC_IP>:~/.openclaw/openclaw.json

scp -i ~/.ssh/openclaw-key.pem -r \
  ./backup-credentials/ \
  ec2-user@<NEW_PUBLIC_IP>:~/.openclaw/

# Restart service
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<NEW_PUBLIC_IP> \
  'sudo systemctl restart openclaw'
```

---

## 🎯 Advanced Scenarios

### Custom Domain Setup

```bash
# After deployment, configure DNS
# Point your domain to the instance IP

# Update Nginx config on instance
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<PUBLIC_IP>

sudo tee /etc/nginx/conf.d/openclaw.conf << 'EOF'
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:3000;
        # ... rest of config
    }
}
EOF

sudo systemctl restart nginx
```

### HTTPS with Let's Encrypt

```bash
# SSH to instance
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<PUBLIC_IP>

# Install certbot
sudo yum install -y certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d your-domain.com

# Auto-renewal is configured automatically
```

### High Availability Setup

Deploy to multiple regions with Terraform:

```bash
# Deploy to us-east-1
cd terraform/openclaw
terraform workspace new us-east-1
terraform apply -var="aws_region=us-east-1"

# Deploy to us-west-2
terraform workspace new us-west-2
terraform apply -var="aws_region=us-west-2"

# Use Route53 for DNS load balancing
```

---

## 🔍 Troubleshooting Replication

### Deployment Fails

**SSH timeout:**
```bash
# Wait longer - instance may be initializing
sleep 120
./scripts/deploy-openclaw.sh
```

**AMI not found:**
```bash
# Use specific AMI ID
export AMI_ID=ami-0c9c942bd7bf113a2
./scripts/deploy-openclaw.sh
```

**Security group exists:**
```bash
# Use existing security group
export SECURITY_GROUP_ID=sg-xxxxx
./scripts/deploy-openclaw.sh
```

### OpenClaw Not Starting

```bash
# Check memory
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<PUBLIC_IP> 'free -h'

# Check logs
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<PUBLIC_IP> \
  'sudo journalctl -u openclaw --no-pager -n 100'

# Increase memory limit
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<PUBLIC_IP>
sudo sed -i 's/max-old-space-size=768/max-old-space-size=1024/' \
  /etc/systemd/system/openclaw.service
sudo systemctl daemon-reload
sudo systemctl restart openclaw
```

### Config Not Applied

```bash
# Verify config exists
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<PUBLIC_IP> \
  'cat ~/.openclaw/openclaw.json | jq .'

# Re-copy config
scp -i ~/.ssh/openclaw-key.pem \
  ~/.openclaw/openclaw.json \
  ec2-user@<PUBLIC_IP>:~/.openclaw/

# Restart
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<PUBLIC_IP> \
  'sudo systemctl restart openclaw'
```

---

## 📊 Cost Management

### Monitor Costs

```bash
# Check instance running time
mise exec -- aws ec2 describe-instances \
  --instance-ids <INSTANCE_ID> \
  --region ap-northeast-2 \
  --query 'Reservations[0].Instances[0].LaunchTime'

# Set up billing alerts in AWS Console
# CloudWatch > Billing > Create Alarm
```

### Optimize Costs

```bash
# Stop instance when not needed (keeps EBS, loses IP)
mise exec -- aws ec2 stop-instances \
  --instance-ids <INSTANCE_ID> \
  --region ap-northeast-2

# Start when needed
mise exec -- aws ec2 start-instances \
  --instance-ids <INSTANCE_ID> \
  --region ap-northeast-2

# Get new IP after start
mise exec -- aws ec2 describe-instances \
  --instance-ids <INSTANCE_ID> \
  --query 'Reservations[0].Instances[0].PublicIpAddress'
```

---

## ✅ Deployment Checklist

### Pre-Deployment

- [ ] AWS credentials configured
- [ ] OpenClaw config ready at `~/.openclaw/openclaw.json`
- [ ] OAuth credentials (if applicable) at `~/.openclaw/credentials/`
- [ ] SSH key pair created (or will be auto-created)
- [ ] Deployment method chosen (bash/terraform/manual)

### During Deployment

- [ ] Instance launches successfully
- [ ] Security groups configured
- [ ] SSH access working
- [ ] OpenClaw installed
- [ ] Nginx configured
- [ ] Services started

### Post-Deployment

- [ ] Web interface accessible at http://<PUBLIC_IP>
- [ ] OAuth authentication working
- [ ] Can create conversations
- [ ] Services auto-start on reboot
- [ ] Logs are clean (no errors)
- [ ] Deployment info saved (openclaw-deployment.env or terraform.tfstate)

### Ongoing Maintenance

- [ ] Monitor memory usage weekly
- [ ] Check logs weekly
- [ ] Update OpenClaw monthly
- [ ] Review AWS costs monthly
- [ ] Test disaster recovery quarterly

---

## 📚 Additional Resources

- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [OpenClaw Documentation](https://github.com/openclaw/openclaw)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/)
- [Nginx Documentation](https://nginx.org/en/docs/)

---

**Last Updated:** 2026-02-14
**Tested On:** Amazon Linux 2023 ARM64, OpenClaw 2026.2.13
