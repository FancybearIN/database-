#!/bin/bash

# Get system IP address
SYSTEM_IP=$(hostname -I | awk '{print $1}')

# Prompt for user input
read -p "Enter GitHub repository URL: " GITHUB_REPO

# Update and install packages
sudo apt update
sudo apt install -y git maven openjdk-17-jdk mariadb-server

# Clone the repository
git clone "$GITHUB_REPO" imart-app

# Build the Java project
cd imart-app
mvn clean package

# Deploy the WAR file (adjust path as needed)
sudo cp target/imart-app.war /var/lib/tomcat9/webapps/

# Restart Tomcat
sudo systemctl restart tomcat9

echo "Deployment complete. Access the application at: http://$SYSTEM_IP:8080/imart-app/"
