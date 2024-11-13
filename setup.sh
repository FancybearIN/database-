#!/bin/bash

# --- Configuration (Customize these) ---
GIT_REPO="https://github.com/FancybearIN/imart.git"
PROJECT_DIR="/var/www/html/imart" 
DB_HOST="localhost"
DB_NAME="imart"  
DB_USER="imart_user"  
DB_PASS="kali" # Use a strong, unique password

# --- 1. Install Dependencies ---
sudo apt update
sudo apt install -y apache2 mysql-server php php-mysql php-mbstring php-gd git 

# --- 2. Configure Apache for Dynamic IP ---
IP_ADDRESS=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
IP_PREFIX=$(echo "$IP_ADDRESS" | cut -d. -f1-3)

cat << EOF > /etc/apache2/sites-available/clinic.conf
<VirtualHost *:80>
    ServerName $IP_PREFIX.*
    DocumentRoot $PROJECT_DIR # Point to the project's directory
    <Directory $PROJECT_DIR>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

sudo a2ensite clinic.conf
sudo a2dissite 000-default.conf
sudo systemctl reload apache2

# --- 3. Database Setup and Population ---
# Create the database and user
sudo mysql -u root -p << EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EXIT
EOF

# --- SQL statements from database.sh (add your SQL statements here) ---
# Example:
# SQL_CREATE_USERS="CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(255) NOT NULL, password VARCHAR(255) NOT NULL);"
# mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "$SQL_CREATE_USERS"

# --- 4. Clone the Repository ---
if [ ! -d "$PROJECT_DIR" ]; then
  sudo git clone "$GIT_REPO" "$PROJECT_DIR"
else
  echo "Project directory already exists. Skipping cloning."
fi

# --- 5. Set Permissions ---
sudo chown -R www-data:www-data "$PROJECT_DIR"
sudo chmod -R 755 "$PROJECT_DIR"

# --- 6. Restart Apache ---
sudo systemctl restart apache2

echo "Setup complete! Access your application at http://$IP_ADDRESS/" 
