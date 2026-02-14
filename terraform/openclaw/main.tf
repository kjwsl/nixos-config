terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source for latest Amazon Linux 2023 ARM AMI
data "aws_ami" "amazon_linux_2023_arm" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-arm64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Security Group
resource "aws_security_group" "openclaw" {
  name        = "openclaw-sg"
  description = "Security group for OpenClaw server"

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "openclaw-sg"
  }
}

# Get current public IP
data "http" "myip" {
  url = "https://checkip.amazonaws.com"
}

# Key Pair (you need to provide the public key)
resource "aws_key_pair" "openclaw" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# EC2 Instance
resource "aws_instance" "openclaw" {
  ami           = data.aws_ami.amazon_linux_2023_arm.id
  instance_type = var.instance_type

  key_name               = aws_key_pair.openclaw.key_name
  vpc_security_group_ids = [aws_security_group.openclaw.id]

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/user-data.sh", {
    openclaw_config = file(var.openclaw_config_path)
  })

  tags = {
    Name = "openclaw-server"
  }
}

# Outputs
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.openclaw.id
}

output "public_ip" {
  description = "Public IP address of the instance"
  value       = aws_instance.openclaw.public_ip
}

output "access_url" {
  description = "OpenClaw web interface URL"
  value       = "http://${aws_instance.openclaw.public_ip}"
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ec2-user@${aws_instance.openclaw.public_ip}"
}
