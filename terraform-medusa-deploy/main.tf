provider "aws" {
  region = "ap-south-1" # Change to your desired region
}

# Generate an SSH key pair to access the EC2 instance
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "medusa_key" {
  key_name   = "medusa-ssh-key"
  public_key = tls_private_key.my_key.public_key_openssh
}

# Define the EC2 instance
resource "aws_instance" "medusa_ec2" {
  ami                         = "ami-0522ab6e1ddcc7055" # Ubuntu 20.04 AMI ID, change according to your region
  instance_type               = "t2.micro"             # Free tier instance type
  key_name                    = aws_key_pair.medusa_key.key_name

  tags = {
    Name = "MedusaEC2"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get upgrade -y
              sudo apt-get install -y nodejs npm git postgresql redis-server
              sudo systemctl enable postgresql
              sudo systemctl start postgresql
              sudo systemctl enable redis-server
              sudo -u postgres psql -c "CREATE USER medusa WITH PASSWORD 'medusa';"
              sudo -u postgres psql -c "CREATE DATABASE medusa;"
              sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE medusa TO medusa;"
              sudo npm install -g @medusajs/medusa-cli
              EOF

  security_groups = [aws_security_group.medusa_sg.name]
}

# Security Group
resource "aws_security_group" "medusa_sg" {
  name_prefix = "medusa-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Output the instance's public IP
output "instance_ip" {
  value = aws_instance.medusa_ec2.public_ip
}

# Output the private key content for GitHub Actions
output "private_key" {
  value = tls_private_key.my_key.private_key_pem
  sensitive = true
}
