# Define the AWS provider and set the region to use for resources
provider "aws" {
  region = var.region
}

# Create a new AWS key pair using the provided public key file
resource "aws_key_pair" "uptime_kuma_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# Create a new security group with specified ingress and egress rules
resource "aws_security_group" "uptime_kuma_sg" {
  name = "uptime_kuma_sg"

  # Ingress rule to allow HTTP traffic on port 80 from any IP address
  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule to allow SSH access on port 22 from any IP address
#   ingress {
#     description = "Allow SSH access"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a new EC2 instance with specified properties
resource "aws_instance" "uptime_kuma" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.uptime_kuma_key.key_name
  security_groups = [aws_security_group.uptime_kuma_sg.name]

  # User data script to configure the instance on startup
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    groupadd docker
    usermod -aG docker $USER
    sleep 15
    docker run -d --restart=always -p 80:3001 -v uptime-kuma:/app/data --name uptime-kuma louislam/uptime-kuma:1
  EOF

  # Tag the instance with a name
  tags = {
    Name = "uptime-kuma"
  }
}

# Allocate an Elastic IP and associate it with the instance
resource "aws_eip" "uptime_kuma_eip" {
  instance = aws_instance.uptime_kuma.id
}

# Output the instance ID
output "instance_id" {
  value = aws_instance.uptime_kuma.id
}

# Output the public IP address of the instance
output "public_ip" {
  value = aws_eip.uptime_kuma_eip.public_ip
}

# Output the key pair name
output "key_pair" {
  value = aws_key_pair.uptime_kuma_key.key_name
}
