#!/bin/bash
yum update -y
yum install -y git
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs
git clone https://github.com/akupheaws/Deploy-2-Tier-Application-With-Terraform-and-Github-Actions.git
cd 2-tier-to-do-list-web-application
echo "DB_HOST=${rds_endpoint}" > .env
echo "DB_USER=${db_username}" >> .env
echo "DB_PASSWORD=${db_password}" >> .env
echo "DB_NAME=SmartTodoWebAppDB" >> .env
echo "PORT=3306" >> .env
echo "API_BASE_URL=http://${public_ip}" >> .env
npm install
npm install -g pm2
pm2 start index.js
pm2 startup
pm2 save
yum install -y nginx
systemctl start nginx
systemctl enable nginx
rm /etc/nginx/nginx.conf
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
            root /home/ec2-user/Deploy-2-Tier-Application-With-Terraform-and-Github-Actions/public;
        }
    }
}
EOT
systemctl restart nginx