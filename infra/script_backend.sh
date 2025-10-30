#!/bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

exec > >(tee -a /var/log/user-data.log)
exec 2>&1
echo "=== Starting frontend deployment at $(date) ==="

BACKEND_URL="http://${backend_ip}:8080"
echo "Backend URL: $BACKEND_URL"

# Install Docker and Git
echo "Installing Docker and Git..."
apt-get update -y
apt-get install -y docker.io git
systemctl enable --now docker
usermod -aG docker ubuntu

# Wait for Docker to be ready
sleep 5

# Clone repository
echo "Cloning repository..."
rm -rf /opt/app
git clone --depth=1 https://github.com/LucasProfetaPXL/cloud2 /opt/app

# Build frontend with correct backend URL
echo "Building frontend with API URL: $BACKEND_URL"
cd /opt/app/frontend

# Build the Docker image with the backend URL
docker build \
  --build-arg APIURL=$BACKEND_URL \
  -t frontend:latest \
  .

# Run the frontend container
echo "Running frontend container..."
docker run -d \
  --name frontend \
  --restart=unless-stopped \
  -p 80:80 \
  frontend:latest

# Wait for container to start
sleep 10

# Check if frontend is running
if docker ps | grep -q frontend; then
  echo "✓ Frontend container is running"
  docker logs frontend
else
  echo "✗ Frontend container failed to start"
  docker logs frontend
  exit 1
fi

echo "Frontend is running on port 80"
echo "Frontend configured to connect to: $BACKEND_URL"
echo "=== Frontend deployment completed at $(date) ==="