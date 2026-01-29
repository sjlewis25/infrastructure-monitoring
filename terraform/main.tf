terraform {
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

# Generate SSH key pair
resource "tls_private_key" "monitoring_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair from generated key
resource "aws_key_pair" "monitoring_key" {
  key_name   = "monitoring-stack-key"
  public_key = tls_private_key.monitoring_key.public_key_openssh

  tags = {
    Name = "monitoring-stack-key"
  }
}

# Save private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.monitoring_key.private_key_pem
  filename        = "${path.module}/monitoring-stack-key.pem"
  file_permission = "0600"
}

# Security Group
resource "aws_security_group" "monitoring_sg" {
  name        = "monitoring-stack-sg"
  description = "Security group for monitoring stack"

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  # Grafana
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Grafana"
  }

  # Prometheus
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Prometheus"
  }

  # AlertManager
  ingress {
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "AlertManager"
  }

  # Node Exporter
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Node Exporter"
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "monitoring-stack-sg"
  }
}

# EC2 Instance
resource "aws_instance" "monitoring" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.monitoring_key.key_name

  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]

  user_data = file("${path.module}/user_data.sh")

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "monitoring-stack"
  }
}