# EVALUATION GUIDE

## Basic Setup Verification
docker network ls
docker compose ps
docker volume ls

## Docker Compose Compliance
grep -E 'network: host|links:' ./srcs/docker-compose.yml  # Should be empty
grep 'networks:' ./srcs/docker-compose.yml                # Should exist
grep -r '^FROM' ./srcs                                    # Must be Alpine/Debian only

## Security & Configuration
grep -r --include=\*.sh --include=Makefile -E 'tail -f|sleep infinity|--link|nginx \&|bash' .
grep -r --include=\*.sh --include=\*.yml -E "latest|password.*=" .

## HTTPS/TLS Testing
curl -I http://matesant.42.fr     # Should fail
curl -I https://matesant.42.fr    # Should work
openssl s_client -connect matesant.42.fr:443 | grep "TLS"

## Container Access & Testing
docker exec -it mariadb mysql -u wp_user -p
docker exec -it nginx nginx -t
docker exec -it wordpress wp user list --allow-root --path=/var/www/wordpress

## Persistence Testing
docker exec -it mariadb mysql -u wp_user -p -e "CREATE TABLE test_table (id INT);" wordpress
docker restart mariadb
docker exec -it mariadb mysql -u wp_user -p -e "SHOW TABLES;" wordpress  # Should persist

## Restart Behavior
docker exec -it mariadb pkill -9 mysqld  # Kill main process inside container
sleep 5
docker ps  # Should show auto-restart

## Cleanup Verification
make fclean
docker ps -a && docker images && docker volume ls && docker network ls  # Should be clean

## Inside MariaDB:
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
SELECT * FROM wp_users;
DESCRIBE wp_posts;