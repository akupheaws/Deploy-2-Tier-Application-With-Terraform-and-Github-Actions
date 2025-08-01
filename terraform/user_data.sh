#!/bin/bash
# Enable verbose logging for easier debugging
set -x

# Update all packages on the system
sudo dnf update -y

# Install Apache web server (httpd), PHP, and the MySQL driver for PHP
sudo dnf install -y httpd php php-mysqlnd

# Install the MariaDB package, which provides the mysql command on AL2023
sudo dnf install -y mariadb

# Start the Apache web server
sudo systemctl start httpd

# Enable the Apache web server to start on boot
sudo systemctl enable httpd

# --- Your Application Deployment Logic Goes Here ---
# The following is an EXAMPLE of how to write the database credentials
# passed from Terraform into a config file for your PHP application.
# You should replace this with your actual deployment steps (e.g., git clone).

cat <<EOF > /var/www/html/config.php
<?php
define('DB_SERVER', '${rds_endpoint}');
define('DB_USERNAME', '${db_username}');
define('DB_PASSWORD', '${db_password}');
define('DB_DATABASE', 'SmartTodoWebAppDB');
?>
EOF

# Set the correct ownership for the web root directory
sudo chown -R apache:apache /var/www/html

# Restart Apache to ensure all changes are applied
sudo systemctl restart httpd