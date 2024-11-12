#!/bin/bash

# --- Configuration (Customize these) ---
GIT_REPO="https://github.com/FancybearIN/clinic.git"
PROJECT_DIR="/var/www/html/clinic" 
DB_HOST="localhost"
DB_NAME="imart"  # Using the database name from database.sh
DB_USER="imart_user"  # Using the database user from database.sh
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
    DocumentRoot $PROJECT_DIR/public # Point to the project's public directory
    <Directory $PROJECT_DIR/public>
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

# --- SQL statements from database.sh ---
SQL_CREATE_CATEGORY="
CREATE TABLE IF NOT EXISTS category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL
);"

SQL_CREATE_CUSTOMER="
CREATE TABLE IF NOT EXISTS customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL
);"

SQL_CREATE_ORDERS="
CREATE TABLE IF NOT EXISTS orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATETIME NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);"

SQL_CREATE_ORDER_ITEM="
CREATE TABLE IF NOT EXISTS order_item (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);"

SQL_CREATE_PAYMENT="
CREATE TABLE IF NOT EXISTS payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    payment_date DATETIME NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(255) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);"

SQL_CREATE_PRODUCT="
CREATE TABLE IF NOT EXISTS product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT,
    product_name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (category_id) REFERENCES category(category_id)
);"

SQL_CREATE_REVIEW="
CREATE TABLE IF NOT EXISTS review (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    customer_id INT,
    rating INT NOT NULL,
    comment TEXT,
    review_date DATETIME NOT NULL,
    FOREIGN KEY (product_id) REFERENCES product(product_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);"

# Execute the SQL statements to create tables
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" << EOF
$SQL_CREATE_CATEGORY
$SQL_CREATE_CUSTOMER
$SQL_CREATE_ORDERS
$SQL_CREATE_ORDER_ITEM
$SQL_CREATE_PAYMENT
$SQL_CREATE_PRODUCT
$SQL_CREATE_REVIEW
EOF

# --- 4. Clone the Repository ---
if [ ! -d "$PROJECT_DIR" ]; then
  sudo git clone "$GIT_REPO" "$PROJECT_DIR"
else
  echo "Project directory already exists. Skipping cloning."
fi

# --- 5. Set Permissions ---
sudo chown -R www-data:www-data "$PROJECT_DIR"
sudo chmod -R 755 "$PROJECT_DIR"

echo "Setup complete! Access your clinic application at http://$IP_ADDRESS/" 
