#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Define repo name as a variable
REPO_NAME="Deploy-2-Tier-Application-With-Terraform-and-Github-Actions"
APP_DIR="/home/ec2-user/$REPO_NAME"

# Install required system packages using DNF (Amazon Linux 2023)
sudo dnf update -y
sudo dnf install -y git gcc-c++ make nginx

# Enable and install Node.js 20 module (compatible with AL2023)
sudo dnf module enable nodejs:20 -y
sudo dnf install -y nodejs

# Clone the application
git clone "https://github.com/akupheaws/$REPO_NAME.git"
cd "$APP_DIR"

# Create .env file using environment variables (replace these at runtime or use Terraform interpolation)
echo "DB_HOST=${rds_endpoint}" > .env
echo "DB_USER=${db_username}" >> .env
echo "DB_PASSWORD=${db_password}" >> .env
echo "DB_NAME=SmartTodoWebAppDB" >> .env
echo "PORT=3306" >> .env
echo "API_BASE_URL=http://${public_ip}" >> .env

# Install app dependencies and run with PM2
npm install
sudo npm install -g pm2
pm2 start index.js
pm2 save

# Set up PM2 to start on boot for ec2-user
env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ec2-user --hp /home/ec2-user

# Start and enable nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Overwrite the Nginx configuration
sudo bash -c "cat > /etc/nginx/nginx.conf" <<EOT
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
            root $APP_DIR/public;
        }
    }
}
EOT

# Restart Nginx to apply new config
sudo systemctl restart nginx
