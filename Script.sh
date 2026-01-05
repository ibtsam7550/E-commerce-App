#!/bin/bash

#=============================================
# Deploy E-Commerce App on RHEL 10 EC2
#=============================================

# Exit on error
set -e

echo "=== Updating system packages ==="
sudo dnf update -y

#---------------------------------------------
# Install Firewall and Open Ports
#---------------------------------------------
echo "=== Installing and configuring firewall ==="
sudo dnf install -y firewalld
sudo systemctl enable --now firewalld
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=3306/tcp
sudo firewall-cmd --reload

#---------------------------------------------
# Install Apache & PHP
#---------------------------------------------
echo "=== Installing Apache and PHP ==="
sudo dnf install -y httpd php php-mysqlnd git
sudo systemctl enable --now httpd

# Ensure PHP works
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php > /dev/null

#---------------------------------------------
# Install MariaDB
#---------------------------------------------
echo "=== Installing MariaDB ==="
sudo dnf install -y mariadb-server mariadb

sudo systemctl enable --now mariadb

# Optional: Run secure installation automatically
# For testing purposes, we skip root password and anonymous removal
echo "=== MariaDB installed and running ==="

#---------------------------------------------
# Create database and user
#---------------------------------------------
echo "=== Creating database and user ==="
sudo mysql <<EOF
CREATE DATABASE IF NOT EXISTS ecomdb;
CREATE USER IF NOT EXISTS 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
GRANT ALL PRIVILEGES ON ecomdb.* TO 'ecomuser'@'localhost';
FLUSH PRIVILEGES;
EOF

#---------------------------------------------
# Load product data
#---------------------------------------------
echo "=== Loading product inventory ==="
cat > db-load-script.sql <<EOF
USE ecomdb;
CREATE TABLE IF NOT EXISTS products (
    id MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT,
    Name VARCHAR(255) DEFAULT NULL,
    Price VARCHAR(255) DEFAULT NULL,
    ImageUrl VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (id)
) AUTO_INCREMENT=1;

INSERT INTO products (Name, Price, ImageUrl) VALUES
("Laptop","100","c-1.png"),
("Drone","200","c-2.png"),
("VR","300","c-3.png"),
("Tablet","50","c-5.png"),
("Watch","90","c-6.png"),
("Phone Covers","20","c-7.png"),
("Phone","80","c-8.png"),
("Laptop","150","c-4.png");
EOF

sudo mysql < db-load-script.sql

#---------------------------------------------
# Clone E-Commerce App
#---------------------------------------------
echo "=== Cloning e-commerce application ==="
sudo rm -rf /var/www/html/*
sudo git clone https://github.com/kodekloudhub/learning-app-ecommerce.git /var/www/html/

#---------------------------------------------
# Create .env file
#---------------------------------------------
echo "=== Creating .env file ==="
sudo tee /var/www/html/.env > /dev/null <<EOF
DB_HOST=localhost
DB_USER=ecomuser
DB_PASSWORD=ecompassword
DB_NAME=ecomdb
EOF

#---------------------------------------------
# Set Permissions
#---------------------------------------------
echo "=== Setting permissions for Apache ==="
sudo chown -R apache:apache /var/www/html/
sudo chmod -R 755 /var/www/html/

#---------------------------------------------
# Update index.php to load .env (already included in repo)
#---------------------------------------------
# If index.php already contains loadEnv(), skip
# Otherwise, insert loadEnv() code at top of index.php

#---------------------------------------------
# Restart Apache to apply all changes
#---------------------------------------------
echo "=== Restarting Apache ==="
sudo systemctl restart httpd

#---------------------------------------------
# Test Deployment
#---------------------------------------------
echo "=== Deployment complete! ==="
echo "Test your app by visiting: http://<your-ec2-public-ip>/"
echo "PHP info page: http://<your-ec2-public-ip>/info.php"
