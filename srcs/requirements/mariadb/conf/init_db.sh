#!/bin/bash
set -eo pipefail

mysqld --skip-networking --socket=/var/run/mysqld/mysqld.sock &

for i in {30..0}; do
    if echo 'SELECT 1' | mysql -uroot -p"$MYSQL_ROOT_PASSWORD" &> /dev/null; then
        break
    fi
    sleep 1
done

mysql -uroot -p"$MYSQL_ROOT_PASSWORD" <<-EOSQL
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
    CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';
    FLUSH PRIVILEGES;
EOSQL

mysqladmin -uroot -p"$MYSQL_ROOT_PASSWORD" shutdown
exec mysqld --bind-address=0.0.0.0