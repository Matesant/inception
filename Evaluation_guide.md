#!/bin/bash

# ------------------------------------------------------------------------------
# EVALUATION COMMANDS - INCEPTION PROJECT (42)
# ------------------------------------------------------------------------------

# 🌐 Check networks created by Docker
docker network ls

# 🔍 Check for improper use of network: host or links:
grep -E 'network: host|links:' ./srcs/docker-compose.yml

# 🔍 Check if networks are defined (required)
grep 'networks:' ./srcs/docker-compose.yml

# 🚨 Search for dangerous commands in scripts and Makefile
grep -r --include=\*.sh --include=Makefile -E 'tail -f|sleep infinity|--link|nginx \&|bash' .

# 🐧 Check base images of Dockerfiles (must be Alpine or Debian)
grep -r '^FROM' ./srcs

# 🔒 Check the TLS version used in NGINX
openssl s_client -connect matesant.42.fr:443 | grep "TLS"

# 🌐 Test HTTP access (should fail) and HTTPS (should work)
curl -I http://matesant.42.fr     # should fail
curl -I https://matesant.42.fr    # should work

# 💾 Check Docker volumes
docker compose ps
docker volume ls
docker volume inspect <volume_name>

# 🗄️ Access the MariaDB container
docker exec -it mariadb sh

# 📥 Login to the MariaDB database (adjust user)
mysql -u wp_user -p

# 🧠 SQL commands inside MariaDB
# SHOW DATABASES;
# USE wordpress;
# SHOW TABLES;

