#!/bin/bash

# Database credentials (replace with your actual values)
DB_USER="imart_user"
DB_PASSWORD="securepassword"
DB_NAME="imart"

# SQL statements to create the database and tables
SQL_CREATE_DATABASE="CREATE DATABASE IF NOT EXISTS $DB_NAME;"
SQL_USE_DATABASE="USE $DB_NAME;"

# --- Table creation statements ---
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

# Execute the SQL statements using the mysql client
mysql -u "$DB_USER" -p"$DB_PASSWORD" -e "$SQL_CREATE_DATABASE"
mysql -u "$DB_USER" -p"$DB_PASSWORD" -e "$SQL_USE_DATABASE$SQL_CREATE_CATEGORY$SQL_CREATE_CUSTOMER$SQL_CREATE_ORDERS$SQL_CREATE_ORDER_ITEM$SQL_CREATE_PAYMENT$SQL_CREATE_PRODUCT$SQL_CREATE_REVIEW"

echo "Database and tables created successfully!"
