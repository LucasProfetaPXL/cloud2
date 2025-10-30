#!/bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

exec > >(tee -a /var/log/user-data.log)
exec 2>&1
echo "=== Starting backend deployment at $(date) ==="

# Install Docker and Git
apt-get update -y
apt-get install -y docker.io git
systemctl enable --now docker
usermod -aG docker ubuntu

sleep 5

# Clone repository
echo "Cloning repository..."
rm -rf /opt/app
git clone --depth=1 https://github.com/LucasProfetaPXL/cloud2 /opt/app

# Start MongoDB container
echo "Starting MongoDB..."
docker run -d \
  --name mongodb \
  --restart=unless-stopped \
  -p 27017:27017 \
  mongo:5

sleep 10

# Build and run backend
cd /opt/app/backend
docker build -t backend:latest .

docker run -d \
  --name backend \
  --restart=unless-stopped \
  --link mongodb:mongodb \
  -p 8080:3000 \
  -e PORT=3000 \
  -e DBURL="mongodb://mongodb:27017/todoapp" \
  backend:latest

echo "Backend running on port 8080"
echo "MongoDB running on port 27017"
echo "=== Backend deployment completed at $(date) ==="