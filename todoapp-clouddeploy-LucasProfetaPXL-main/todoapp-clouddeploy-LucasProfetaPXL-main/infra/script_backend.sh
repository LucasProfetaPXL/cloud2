#!/bin/bash
# ===== EC2 User Data Script =====

# Loggen naar een bestand (handig voor debugging)
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# Update packages
sudo apt update -y
sudo apt upgrade -y

# Install Git & Docker
sudo apt install -y git docker.io

# Start Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Clone de repo
cd /home/ubuntu
git clone https://github.com/3TIN-CloudExpert/todoapp-clouddeploy-LucasProfetaPXL.git

# Ga naar de backend folder
cd todoapp-clouddeploy-LucasProfetaPXL/backend

# Bouw en run de Dockerfile
sudo docker build -t todoapp-backend .
sudo docker run -d -p 80:80 todoapp-backend
