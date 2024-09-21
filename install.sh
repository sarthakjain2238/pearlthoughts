#!/bin/bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose git
sudo usermod -aG docker ubuntu
sudo systemctl enable docker
sudo systemctl start docker

# Clone the repository into the default folder 'pearlthoughts'
cd /home/ubuntu
git clone https://github.com/sarthakjain2238/pearlthoughts.git

# Change into the correct directory
cd pearlthoughts

# Ensure docker-compose.yml file exists before proceeding
if [ -f "docker-compose.yml" ]; then
  sudo docker-compose up -d --build
else
  echo "ERROR: docker-compose.yml not found!"
  exit 1
fi
