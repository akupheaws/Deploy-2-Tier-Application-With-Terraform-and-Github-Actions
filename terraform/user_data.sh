#!/bin/bash
# Enable verbose logging for debugging
set -x

# Exit on any error to prevent partial setup
set -e

# Remove any incompatible MySQL repositories to prevent dependency issues
sudo rpm -e --nodeps mysql80-community-release-el7 || true
sudo rm -f /etc/yum.repos.d/mysql-community*

# Update all packages
sudo dnf update -y

# Install Apache, PHP, PHP MySQL driver, and MariaDB client (provides mysql command)
sudo dnf install -y httpd php php-mysqlnd mariadb

# Allow HTTP traffic through the firewall
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload

# Start and enable Apache
sudo systemctl start httpd
sudo systemctl enable httpd

# Create directory for PHP config file outside web root for security
sudo mkdir -p /etc/php.d

# Create PHP config file with database credentials
cat <<EOF > /etc/php.d/config.php
<?php
define('DB_SERVER', '${rds_endpoint}');
define('DB_USERNAME', '${db_username}');
define('DB_PASSWORD', '${db_password}');
define('DB_DATABASE', 'SmartTodoWebAppDB');
?>
EOF

# Set secure permissions for config file
sudo chown apache:apache /etc/php.d/config.php
sudo chmod 600 /etc/php.d/config.php

# Set ownership and permissions for web root
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html

# Create a test PHP file to verify database connectivity
cat <<EOF > /var/www/html/test_db.php
<?php
require_once '/etc/php.d/config.php';
\$conn = new mysqli(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_DATABASE);
if (\$conn->connect_error) {
    die("Connection failed: " . \$conn->connect_error);
}
echo "Connected successfully to the database!";
\$conn->close();
?>
EOF

# Set permissions for test file
sudo chown apache:apache /var/www/html/test_db.php
sudo chmod 644 /var/www/html/test_db.php

# Restart Apache to apply changes
sudo systemctl restart httpd

# Verify installations
echo "Verifying installed components:"
httpd -v
php --version
mysql --version

# Log completion
echo "Setup completed successfully. Test database connection at http://<your-server-ip>/test_db.php"