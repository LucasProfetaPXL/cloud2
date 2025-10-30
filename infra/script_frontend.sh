#!/bin/bash
set -e

echo "=== Starting frontend deployment ==="

# Install Docker (if not in AMI)
apt-get update
apt-get install -y docker.io git
systemctl start docker
systemctl enable docker

# Clone and build
cd /opt
git clone https://github.com/your-repo/app.git
cd app

# Use Docker BuildKit for faster builds
export DOCKER_BUILDKIT=1

# Build with build arg
docker build \
  --build-arg APIURL=http://${backend_ip}:8080 \
  -t frontend:latest \
  -f Dockerfile.frontend \
  .

# Run container
docker run -d \
  --name frontend \
  --restart unless-stopped \
  -p 80:80 \
  frontend:latest

echo "=== Frontend deployment complete ==="