#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# Define repo name as a variable
REPO_NAME="Deploy-2-Tier-Application-With-Terraform-and-Github-Actions"
APP_DIR="/home/ec2-user/$REPO_NAME"

# Install dependencies
yum update -y
yum install -y git
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Clone the application
git clone "https://github.com/akupheaws/$REPO_NAME.git"
cd "$APP_DIR"

# Create .env file
# NOTE: Storing passwords in plaintext is a security risk.
# Use a service like AWS Secrets Manager in production.
echo "DB_HOST=${rds_endpoint}" > .env
echo "DB_USER=${db_username}" >> .env
echo "DB_PASSWORD=${db_password}" >> .env
echo "DB_NAME=SmartTodoWebAppDB" >> .env
echo "PORT=3306" >> .env
echo "API_BASE_URL=http://${public_ip}" >> .env

# Install app dependencies and run with PM2
npm install
npm install -g pm2
pm2 start index.js
pm2 save

# Correctly set up PM2 to start on boot
# This captures the output of 'pm2 startup' and runs it with sudo.
env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ec2-user --hp /home/ec2-user

# Install and configure Nginx
yum install -y nginx
systemctl start nginx
systemctl enable nginx

# Overwrite the Nginx configuration
cat <<EOT > /etc/nginx/nginx.conf
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
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host \$host;
            proxy_cache_bypass \$http_upgrade;
        }
        location /static/ {
            # Use the variable for a robust path
            root "$APP_DIR/public";
        }
    }
}
EOT

systemctl restart nginx