# OpenClaw Terraform Deployment

Infrastructure-as-Code deployment for OpenClaw using Terraform.

## Prerequisites

1. **Terraform installed:**
   ```bash
   brew install terraform
   # or use mise
   mise use -g terraform@latest
   ```

2. **AWS credentials configured** (via mise or environment)

3. **SSH key pair generated:**
   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/openclaw-key -N ""
   ```

4. **OpenClaw config ready** at `~/.openclaw/openclaw.json`

## Quick Start

### Deploy

```bash
cd terraform/openclaw

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy
terraform apply
```

### Access Your Instance

After deployment, Terraform will output:
- `access_url` - Web interface URL
- `ssh_command` - SSH command to connect
- `instance_id` - EC2 instance ID
- `public_ip` - Public IP address

Example output:
```
access_url = "http://15.164.228.202"
ssh_command = "ssh -i ~/.ssh/openclaw-key.pem ec2-user@15.164.228.202"
```

### Destroy

```bash
terraform destroy
```

## Customization

### Variables

Create a `terraform.tfvars` file:

```hcl
aws_region           = "us-east-1"
instance_type        = "t4g.small"
key_name             = "my-openclaw-key"
public_key_path      = "~/.ssh/my-openclaw-key.pub"
openclaw_config_path = "~/.openclaw/openclaw.json"
```

### Different Instance Types

Free tier eligible:
- `t4g.micro` - 1GB RAM, 2 vCPUs (ARM) - **Default**
- `t3.micro` - 1GB RAM, 2 vCPUs (x86)

More powerful:
- `t4g.small` - 2GB RAM, 2 vCPUs (ARM) - **Recommended for production**
- `t4g.medium` - 4GB RAM, 2 vCPUs (ARM)

## Features

- ✅ Automated EC2 instance provisioning
- ✅ Security group configuration
- ✅ SSH key management
- ✅ OpenClaw installation and configuration
- ✅ Nginx reverse proxy setup
- ✅ Swap space configuration
- ✅ Systemd service creation
- ✅ Automatic startup on boot

## State Management

Terraform state is stored locally by default. For team use or CI/CD, configure remote state:

```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "openclaw/terraform.tfstate"
    region = "ap-northeast-2"
  }
}
```

## Cost Estimate

**AWS Free Tier:**
- EC2: 750 hours/month free (first 12 months)
- Storage: 30GB free
- Data transfer: 100GB/month free

**After free tier:**
- t4g.micro: ~$6/month
- 20GB EBS: ~$2/month
- Data transfer: ~$1/month
- **Total: ~$9/month**

## Troubleshooting

### SSH Connection Refused

Wait 60 seconds after deployment for instance initialization.

### OpenClaw Not Starting

Check logs:
```bash
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<PUBLIC_IP> \
  'sudo journalctl -u openclaw -n 50'
```

### Config Not Applied

Verify user-data execution:
```bash
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<PUBLIC_IP> \
  'cat /var/log/openclaw-setup.log'
```

## Advanced Usage

### Multiple Environments

```bash
# Production
terraform workspace new production
terraform apply -var-file=production.tfvars

# Staging
terraform workspace new staging
terraform apply -var-file=staging.tfvars
```

### Import Existing Resources

```bash
terraform import aws_instance.openclaw i-0942512f150ad90b1
```

## Comparison with Bash Script

| Feature | Bash Script | Terraform |
|---------|-------------|-----------|
| Setup speed | Faster | Slower (plan review) |
| Idempotency | Manual | Automatic |
| State tracking | Manual | Built-in |
| Multi-environment | Hard | Easy |
| Team collaboration | Difficult | Built-in |
| Drift detection | No | Yes |

**Use bash script for:** Quick one-off deployments, testing
**Use Terraform for:** Production, teams, multiple environments
