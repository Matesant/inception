#!/bin/bash

service mariadb start

mariadb -u root -e "CREATE DATABASE IF NOT EXISTS ${WP_DATABASE};"
mariadb -u root -e "CREATE USER '${WP_USER}'@'%' IDENTIFIED BY '${WP_PASSWORD}';"
mariadb -u root -e "GRANT ALL ON ${WP_DATABASE}.* TO '${WP_USER}'@'%' \
                    IDENTIFIED BY '${WP_PASSWORD}';"
mariadb -u root -e "FLUSH PRIVILEGES;"