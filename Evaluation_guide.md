#!/bin/bash

# ------------------------------------------------------------------------------
# EVALUATION COMMANDS - INCEPTION PROJECT (42)
# ------------------------------------------------------------------------------

# Check networks created by Docker
docker network ls

# Check for improper use of network: host or links:
grep -E 'network: host|links:' ./srcs/docker-compose.yml

# Check if networks are defined (required)
grep 'networks:' ./srcs/docker-compose.yml

# Search for dangerous commands in scripts and Makefile
grep -r --include=\*.sh --include=Makefile -E 'tail -f|sleep infinity|--link|nginx \&|bash' .

# Check base images of Dockerfiles (must be Alpine or Debian)
grep -r '^FROM' ./srcs

# Check the TLS version used in NGINX
openssl s_client -connect matesant.42.fr:443 | grep "TLS"

# Test HTTP access (should fail) and HTTPS (should work)
curl -I http://matesant.42.fr     # should fail
curl -I https://matesant.42.fr    # should work

# Check Docker volumes
docker compose ps
docker volume ls
docker volume inspect <volume_name>

# Access the MariaDB container
docker exec -it mariadb sh

# Login to the MariaDB database (adjust user)
mysql -u wp_user -p

# SQL commands inside MariaDB
# SHOW DATABASES;
# USE wordpress;
# SHOW TABLES;

# Check WordPress container
docker exec -it wordpress sh

# Inside WordPress container - check WP-CLI
wp --version --allow-root
wp core version --allow-root --path=/var/www/wordpress
wp user list --allow-root --path=/var/www/wordpress

# Check NGINX container
docker exec -it nginx sh

# Inside NGINX - check SSL certificates
ls -la /etc/nginx/ssl/
openssl x509 -in /etc/nginx/ssl/nginx.crt -text -noout

# Check volumes content
docker exec -it wordpress ls -la /var/www/wordpress
docker exec -it mariadb ls -la /var/lib/mysql

# Test restart behavior (containers should restart automatically)
docker stop mariadb
docker stop wordpress
docker stop nginx
sleep 10
docker ps  # Should show containers restarting

# Test database persistence
docker exec -it mariadb mysql -u wp_user -p -e "CREATE TABLE test_table (id INT);" wordpress
docker restart mariadb
docker exec -it mariadb mysql -u wp_user -p -e "SHOW TABLES;" wordpress  # Should still have test_table

# Test WordPress admin access
curl -k https://matesant.42.fr/wp-admin/

# Check if WordPress has admin and regular user
docker exec -it wordpress wp user list --allow-root --path=/var/www/wordpress

# Check if services are properly built from Dockerfile (no pre-built images)
docker images | grep -E "(nginx|alpine|debian)"

# Check for .env file and secrets
cat ./srcs/.env
find . -name "*.env*"

# Check for forbidden patterns
grep -r --include=\*.sh --include=\*.yml -E "latest|password.*=" .
grep -r --include=\*.sh -E "service.*start|systemctl" ./srcs

# Check process management in containers
docker exec -it nginx ps aux
docker exec -it wordpress ps aux
docker exec -it mariadb ps aux

# Test domain resolution
ping matesant.42.fr
nslookup matesant.42.fr

# Makefile functionality tests
make info
make down
make up
make clean

# Check resource usage
docker stats --no-stream

# Security checks
docker exec -it nginx nginx -t  # Test nginx config
docker exec -it mariadb mysqld --help --verbose | grep ssl  # Check SSL support

# Cleanup verification
make fclean
docker ps -a  # Should be empty
docker images  # Should not have project images
docker volume ls  # Should not have project volumes
docker network ls  # Should not have project networks

