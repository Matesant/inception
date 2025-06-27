#!/bin/bash

# Create necessary directories and set permissions
mkdir -p /var/run/mysqld
chown mysql:mysql /var/run/mysqld
chmod 755 /var/run/mysqld

# Fix permissions for the database directory
# Only change ownership of files we can actually change
find /var/lib/mysql -type d -exec chown mysql:mysql {} \; 2>/dev/null || true
find /var/lib/mysql -type f -exec chown mysql:mysql {} \; 2>/dev/null || true

# Initialize MariaDB if not already initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --auth-root-authentication-method=normal
    chown -R mysql:mysql /var/lib/mysql 2>/dev/null || true
fi

# Start MariaDB temporarily to configure it
echo "Starting MariaDB for initial configuration..."
mysqld_safe --user=mysql --datadir=/var/lib/mysql --socket=/var/run/mysqld/mysqld.sock &
MYSQL_PID=$!

# Wait for MariaDB to start
echo "Waiting for MariaDB to start..."
for i in {1..30}; do
    if mysqladmin ping --socket=/var/run/mysqld/mysqld.sock --silent; then
        break
    fi
    echo "Waiting for MariaDB... ($i/30)"
    sleep 2
done

# Check if MariaDB started successfully
if ! mysqladmin ping --socket=/var/run/mysqld/mysqld.sock --silent; then
    echo "ERROR: MariaDB failed to start"
    exit 1
fi

# Set root password and create database/user
echo "Configuring MariaDB..."
mysql --socket=/var/run/mysqld/mysqld.sock << EOF
-- Set root password
UPDATE mysql.user SET Password=PASSWORD('${MYSQL_ROOT_PASSWORD}') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Create database and user
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';
FLUSH PRIVILEGES;
EOF

# Stop the temporary MariaDB instance
echo "Stopping temporary MariaDB instance..."
mysqladmin --socket=/var/run/mysqld/mysqld.sock -u root -p${MYSQL_ROOT_PASSWORD} shutdown

# Start MariaDB in foreground for production
echo "Starting MariaDB in production mode..."
exec mysqld --user=mysql --datadir=/var/lib/mysql --socket=/var/run/mysqld/mysqld.sock --bind-address=0.0.0.0 --port=3306