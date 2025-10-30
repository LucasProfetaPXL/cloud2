#!/bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

exec > >(tee -a /var/log/user-data.log)
exec 2>&1
echo "=== Starting backend deployment at $(date) ==="

# Install Docker
apt-get update -y
apt-get install -y docker.io git
systemctl enable --now docker
usermod -aG docker ubuntu

# Clone and run backend
echo "Cloning repository..."
rm -rf /opt/app
git clone --depth=1 https://github.com/LucasProfetaPXL/cloud2 /opt/app

echo "Building and running backend container..."
cd /opt/app/backend
docker build -t backend:latest .
docker run -d --name backend --restart=unless-stopped -p 8080:8080 backend:latest

echo "Backend is running on port 8080"
echo "=== Backend deployment completed at $(date) ==="