variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "ap-northeast-2"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t4g.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "openclaw-key"
}

variable "public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "~/.ssh/openclaw-key.pub"
}

variable "openclaw_config_path" {
  description = "Path to OpenClaw configuration file"
  type        = string
  default     = "~/.openclaw/openclaw.json"
}
