# AWS Deployment Patterns

## Memory-Constrained Node.js Services

**Template:**
```bash
# Systemd service
Environment="NODE_OPTIONS=--max-old-space-size=768"

# Swap (2x RAM)
dd if=/dev/zero of=/swapfile bs=1M count=2048
chmod 600 /swapfile
mkswap /swapfile && swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

## Nginx Reverse Proxy for Localhost Services

**Pattern:** Expose localhost-only services
```nginx
server {
    listen 80;
    location / {
        proxy_pass http://127.0.0.1:PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 86400;
    }
}
```

## Three-Tier Deployment Strategy

1. **Bash Script** - Quick testing, one-offs
2. **Terraform** - Production, state management
3. **Manual** - Learning, troubleshooting

**Key:** Reuse installation scripts across all methods

## Config Replication Pattern

```bash
# Copy authenticated configs
ssh user@new-ip 'mkdir -p ~/.service'
scp -r ~/.service/config.json user@new-ip:~/.service/
scp -r ~/.service/credentials user@new-ip:~/.service/
ssh user@new-ip 'systemctl restart service'
```

## Troubleshooting Flow

1. `systemctl status service`
2. `journalctl -u service -n 50`
3. `free -h` (check memory)
4. `ss -tlnp | grep PORT` (check binding)
5. `curl -I http://localhost:PORT` (test locally)
