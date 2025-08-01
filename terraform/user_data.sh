#!/bin/bash
# Enable verbose logging for easier debugging
set -x

# Update all packages on the system
sudo dnf update -y

# Clean old or broken GPG keys for MySQL (if installed before)
sudo rpm -e gpg-pubkey-5072e1f5* || true

# Import the correct latest GPG key from MySQL
sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022

# Optional: Clean any previously cached packages
sudo dnf clean packages

# Install Apache web server (httpd), PHP, and the MySQL driver for PHP
# Note: This is an example for a PHP app; your actual app uses Node.js,
# which is installed later by the GitHub Actions workflow.
# This script still provides a valid base system.
sudo dnf install -y httpd php php-mysqlnd

# Install the MariaDB package (which provides the `mysql` client on AL2023)
sudo dnf install -y mariadb

# Start the Apache web server
sudo systemctl start httpd

# Enable the Apache web server to start on boot
sudo systemctl enable httpd
