#!/bin/bash
set -e

# Update and install required packages
sudo dnf update -y
sudo dnf install -y git nginx mariadb

# Install Node.js and PM2
curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo dnf install -y nodejs
sudo npm install -g pm2

# Clone repo
rm -rf Deploy-2-Tier-Application-With-Terraform-and-Github-Actions
git clone https://github.com/akupheaws/Deploy-2-Tier-Application-With-Terraform-and-Github-Actions.git
cd Deploy-2-Tier-Application-With-Terraform-and-Github-Actions

# Create .env
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
cat <<EOT > .env
DB_HOST=$1
DB_USER=$2
DB_PASSWORD=$3
DB_NAME=SmartTodoWebAppDB
PORT=3000
API_BASE_URL=http://$PUBLIC_IP
EOT

# Start app
npm install
pm2 start index.js || pm2 restart index.js
pm2 save
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u ec2-user --hp /home/ec2-user

# Setup nginx
sudo bash -c 'cat <<NGINX > /etc/nginx/nginx.conf
events {
  worker_connections 1024;
}
http {
  server {
    listen 80;
    server_name _;
    location / {
      proxy_pass http://localhost:3000;
      proxy_http_version 1.1;
      proxy_set_header Upgrade \$http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_set_header Host \$host;
      proxy_cache_bypass \$http_upgrade;
    }
  }
}
NGINX'

sudo systemctl restart nginx
sudo systemctl enable nginx
