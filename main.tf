provider "aws" {
  region = "ap-south-1"
}

variable "ec2_private_key" {
  type      = string
  sensitive = true
}

resource "aws_instance" "medusa_ec2" {
  ami                    = "ami-0522ab6e1ddcc7055" # Ubuntu 22.04 LTS AMI
  instance_type          = "t2.micro"  # Instance type; increase if facing timeouts
  key_name               = "tits"      # Replace with your actual key pair name
  vpc_security_group_ids = ["sg-0b3d4418cb212fc4a"]  # Security group ID

  tags = {
    Name = "MedusaEC2"
  }

  # File provisioner to transfer install.sh script to the EC2 instance
  provisioner "file" {
    source      = "install.sh"                  # Local path of the script
    destination = "/home/ubuntu/install.sh"     # Destination on the EC2 instance

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = var.ec2_private_key          # Use the private key from the variable
      host        = self.public_ip               # Connect to the instance's public IP
    }
  }

  # Remote exec provisioner to execute the transferred script
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/install.sh",        # Make the script executable
      "/home/ubuntu/install.sh"                  # Run the script
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = var.ec2_private_key          # Use the private key from the variable
      host        = self.public_ip               # Connect to the instance's public IP
    }
  }
}

# Output the EC2 instance's public IP after deployment
output "ec2_public_ip" {
  value = aws_instance.medusa_ec2.public_ip
}
