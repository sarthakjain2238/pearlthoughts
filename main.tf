# Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Allow SSH and HTTP"
  vpc_id      = "vpc-0cf25e1abb1c35925 "

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH access (be cautious)
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Medusa backend port
  }

    # Allow HTTP traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP access from anywhere
  }

  # Allow HTTPS traffic
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTPS access from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "medusa_instance" {
  ami           = "ami-0522ab6e1ddcc7055"
  instance_type = "t2.micro"
  key_name      = var.ec2_key_pair  # The key pair for SSH access
  security_groups = [
    aws_security_group.ec2_sg.name
  ]
  tags = {
    Name = "Medusa Backend"
  }
}

data "aws_instance" "medusa" {
  instance_id = aws_instance.medusa_instance.id
}