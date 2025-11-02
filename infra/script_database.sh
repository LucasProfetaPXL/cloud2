#!/bin/bash
set -euo pipefail
apt-get update -y
apt-get install -y docker.io
systemctl enable --now docker
usermod -aG docker ubuntu

sleep 5

# Start MongoDB container
echo "Starting MongoDB..."
docker run -d --name mongodb --restart=unless-stopped -p 27017:27017 mongo:5