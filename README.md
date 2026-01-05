# E-Commerce Application Deployment on RHEL 10 BY USING SHELL-SCRIPT

## Introduction

This repository contains a sample **e-commerce application** along with a **deployment script** to set it up on a **RHEL 10 EC2 instance**.  
The script installs and configures:

- Firewall  
- Apache and PHP  
- MariaDB database  
- Application code and `.env` file  
- Permissions for Apache  

After running the script, the app will be fully functional and ready to use.

---

## Prerequisites

- RHEL 10 EC2 instance  
- Sudo privileges  
- Internet access to install packages and clone the repo  

---

## Deployment Steps

1. **Clone the Repository**

```bash
git clone https://github.com/ibtsam7550/E-commerce-App.git
cd E-commerce-App
```
---
2. **Make the Deployment Script Executable**

```
sudo chmod +x script.sh
```
---
3. **Run the Deployment Script**

```
sudo ./script.sh
```
The script will automatically:

 - Install firewall and open ports 80 (HTTP) and 3306 (MariaDB)
 - Install Apache, PHP, and Git
 - Install MariaDB and create the ecomdb database and ecomuser
 - Load product inventory into the database
 - Clone the e-commerce app into /var/www/html/
 - Create the .env file
 - Set proper file permissions
 - Restart Apache

---
4. **Access the Application**

Open your browser and visit your EC2 public IP:
```
http://<your-ec2-public-ip>/
```
---
**Notes**

- The script uses default MariaDB credentials (ecomuser/ecompassword) for testing.
- For production, consider securing `MariaDB`, removing test databases, and enabling `HTTPS`.
- On multi-node setups, update the `.env` file with the database server IP instead of `localhost`.

**Deployment is complete! Your e-commerce application is ready to use.**
