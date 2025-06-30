#!/bin/bash

# Initialize MariaDB if not already done
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start MariaDB temporarily to configure
service mariadb start
sleep 5

# Wait for MariaDB to be ready
while ! mysqladmin ping --silent; do
    echo "Waiting for MariaDB to start..."
    sleep 1
done

# Set root password and create database/user
mariadb -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWORD}');"
mariadb -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
mariadb -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mariadb -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO \`${MYSQL_USER}\`@'%';"
mariadb -e "FLUSH PRIVILEGES;"

# Shutdown temporary instance
mysqladmin -u root -p$MYSQL_ROOT_PASSWORD shutdown

# Start MariaDB in foreground for Docker
echo "Starting MariaDB in production mode..."
exec mysqld_safe --port=3306 --bind-address=0.0.0.0 --datadir='/var/lib/mysql'