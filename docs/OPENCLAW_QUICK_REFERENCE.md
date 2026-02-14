# OpenClaw Quick Reference Card

One-page cheat sheet for OpenClaw AWS deployment.

## 🚀 Deploy

```bash
# Automated deployment
./scripts/deploy-openclaw.sh

# Terraform deployment
cd terraform/openclaw && terraform apply
```

## 🔍 Check Status

```bash
# Service status
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<IP> 'sudo systemctl status openclaw nginx'

# Logs
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<IP> 'sudo journalctl -u openclaw -f'

# Memory usage
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<IP> 'free -h'
```

## 🔧 Manage Services

```bash
# Restart
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<IP> 'sudo systemctl restart openclaw nginx'

# Stop
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<IP> 'sudo systemctl stop openclaw nginx'

# Start
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<IP> 'sudo systemctl start openclaw nginx'
```

## 📝 Update Config

```bash
# Copy new config
scp -i ~/.ssh/openclaw-key.pem ~/.openclaw/openclaw.json ec2-user@<IP>:~/.openclaw/

# Restart service
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<IP> 'sudo systemctl restart openclaw'
```

## 🆙 Update OpenClaw

```bash
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<IP> << 'EOF'
sudo npm update -g openclaw
sudo systemctl restart openclaw
EOF
```

## 🧹 Teardown

```bash
# Bash script cleanup
./scripts/teardown-openclaw.sh

# Terraform cleanup
cd terraform/openclaw && terraform destroy
```

## 🔒 Instance Control

```bash
# Stop instance (saves costs, keeps data, loses IP)
mise exec -- aws ec2 stop-instances --instance-ids <ID> --region ap-northeast-2

# Start instance
mise exec -- aws ec2 start-instances --instance-ids <ID> --region ap-northeast-2

# Terminate instance (deletes everything)
mise exec -- aws ec2 terminate-instances --instance-ids <ID> --region ap-northeast-2
```

## 📊 Get Info

```bash
# Public IP
mise exec -- aws ec2 describe-instances --instance-ids <ID> --region ap-northeast-2 \
  --query 'Reservations[0].Instances[0].PublicIpAddress' --output text

# Instance status
mise exec -- aws ec2 describe-instances --instance-ids <ID> --region ap-northeast-2 \
  --query 'Reservations[0].Instances[0].State.Name' --output text
```

## 🐛 Troubleshoot

```bash
# Check if OpenClaw is running
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<IP> 'pgrep -a openclaw'

# Check port 3000
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<IP> 'ss -tlnp | grep 3000'

# Test local access
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<IP> 'curl -I http://localhost:3000'

# Check Nginx
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<IP> 'sudo nginx -t'

# Full logs
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<IP> \
  'sudo journalctl -u openclaw --no-pager -n 100'
```

## 📂 File Locations

| Item | Path |
|------|------|
| Config | `~/.openclaw/openclaw.json` |
| Credentials | `~/.openclaw/credentials/` |
| Service | `/etc/systemd/system/openclaw.service` |
| Nginx | `/etc/nginx/conf.d/openclaw.conf` |
| Logs | `journalctl -u openclaw` |
| Local SSH Key | `~/.ssh/openclaw-key.pem` |

## 🌐 Access Points

| Service | URL |
|---------|-----|
| Web Interface | `http://<PUBLIC_IP>` |
| OpenClaw Gateway | `http://localhost:3000` (from instance) |
| Nginx | `http://<PUBLIC_IP>:80` |

## ⚙️ Configuration

### Change Memory Limit

```bash
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<IP>
sudo sed -i 's/max-old-space-size=768/max-old-space-size=1024/' \
  /etc/systemd/system/openclaw.service
sudo systemctl daemon-reload
sudo systemctl restart openclaw
```

### Change Port

```bash
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<IP>
sudo sed -i 's/--port 3000/--port 3001/' \
  /etc/systemd/system/openclaw.service
sudo sed -i 's/127.0.0.1:3000/127.0.0.1:3001/' \
  /etc/nginx/conf.d/openclaw.conf
sudo systemctl daemon-reload
sudo systemctl restart openclaw nginx
```

## 💰 Cost Info

| Item | Free Tier | After Free Tier |
|------|-----------|-----------------|
| t4g.micro | 750h/month | ~$6/month |
| 20GB EBS | 30GB/month | ~$2/month |
| Data Transfer | 100GB/month | ~$1/GB |
| **Total** | $0 | ~$9/month |

## 🔑 Environment Variables

```bash
export AWS_REGION=ap-northeast-2
export INSTANCE_TYPE=t4g.micro
export KEY_NAME=openclaw-key
```

## 📞 Support

- **Docs:** `~/repos/home-manager/docs/`
- **Deployment Info:** `openclaw-deployment.env` or `terraform.tfstate`
- **Current Deployment:** http://15.164.228.202
- **Instance ID:** i-0942512f150ad90b1
