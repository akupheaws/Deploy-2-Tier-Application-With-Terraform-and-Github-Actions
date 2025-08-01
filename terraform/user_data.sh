#!/bin/bash
set -x

# Update all packages
sudo dnf update -y

# Install required packages
sudo dnf install -y git nginx mariadb

# Install Node.js 16 from official NodeSource
curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo dnf install -y nodejs

# Enable and start nginx
sudo systemctl enable nginx
sudo systemctl start nginx
