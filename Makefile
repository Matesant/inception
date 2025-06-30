#------------------------------------------------------------------------------#
#                                VARIABLES                                     #
#------------------------------------------------------------------------------#

USER            =   $(shell whoami)
LOGIN			=	matesant
VOLUME_PATH     =   /home/$(LOGIN)/data
WORDPRESS_PATH  =   $(VOLUME_PATH)/wordpress
MARIADB_PATH    =   $(VOLUME_PATH)/mariadb
MYSQLD_RUN_PATH =   $(VOLUME_PATH)/mysqld_run
HOST_FILE       =   /etc/hosts
DOMAIN          =   matesant.42.fr
COMPOSE_FILE    =   srcs/docker-compose.yml
DOT_ENV_FILE    =   srcs/.env

# Colors
GREEN           =   \033[32m
RED             =   \033[31m
CYAN            =   \033[36m
YELLOW          =   \033[33m
RESET           =   \033[0m

#------------------------------------------------------------------------------#
#                                 TARGETS                                      #
#------------------------------------------------------------------------------#

.PHONY: all up down clean fclean re setup info

all: setup up

## Start containers
up:
	@echo "$(CYAN)Starting containers...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) --env-file $(DOT_ENV_FILE) up -d --build

## Stop containers
down:
	@echo "$(RED)Stopping containers...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) down

## Set up environment: .env, hosts
setup:
	@echo "$(GREEN)Setting up environment...$(RESET)"
	@if ! grep -q '$(DOMAIN)' $(HOST_FILE); then \
		echo "$(YELLOW)Adding $(DOMAIN) to $(HOST_FILE)...$(RESET)"; \
		echo "127.0.0.1	$(DOMAIN)" | sudo tee -a $(HOST_FILE); \
	fi
	@if [ ! -f "$(DOT_ENV_FILE)" ]; then \
		echo "$(YELLOW)Creating .env file...$(RESET)"; \
		echo "# Database" > $(DOT_ENV_FILE); \
		echo "MYSQL_ROOT_PASSWORD=rootpass" >> $(DOT_ENV_FILE); \
		echo "MYSQL_DATABASE=wordpress" >> $(DOT_ENV_FILE); \
		echo "MYSQL_USER=wp_user" >> $(DOT_ENV_FILE); \
		echo "MYSQL_PASSWORD=wp_pass" >> $(DOT_ENV_FILE); \
		echo "" >> $(DOT_ENV_FILE); \
		echo "# WordPress Admin" >> $(DOT_ENV_FILE); \
		echo "WP_TITLE=Inception WP" >> $(DOT_ENV_FILE); \
		echo "WP_ADMIN=owner42" >> $(DOT_ENV_FILE); \
		echo "WP_ADMIN_PASS=owner42_pass" >> $(DOT_ENV_FILE); \
		echo "WP_ADMIN_EMAIL=owner42@42.fr" >> $(DOT_ENV_FILE); \
		echo "" >> $(DOT_ENV_FILE); \
		echo "# Viewer user" >> $(DOT_ENV_FILE); \
		echo "WP_VIWER_USER=viewer" >> $(DOT_ENV_FILE); \
		echo "WP_VIWER_PASSWORD=viewer_pass" >> $(DOT_ENV_FILE); \
		echo "WP_VIWER_EMAIL=viewer@example.com" >> $(DOT_ENV_FILE); \
		echo "" >> $(DOT_ENV_FILE); \
		echo "# WordPress config" >> $(DOT_ENV_FILE); \
		echo "WORDPRESS_DB_HOST=mariadb" >> $(DOT_ENV_FILE); \
	fi

## Clean containers and networks
clean: down
	@echo "$(RED)Cleaning containers, images and volumes...$(RESET)"
	@if [ $$(docker ps -q | wc -l) -gt 0 ]; then docker stop $$(docker ps -q); fi
	@if [ $$(docker ps -aq | wc -l) -gt 0 ]; then docker rm $$(docker ps -aq); fi
	@if [ $$(docker images -q | wc -l) -gt 0 ]; then docker rmi $$(docker images -q); fi
	@if [ $$(docker volume ls -q | wc -l) -gt 0 ]; then docker volume rm $$(docker volume ls -q); fi
	@if [ $$(docker network ls -q --filter type=custom | wc -l) -gt 0 ]; then docker network rm $$(docker network ls -q --filter type=custom); fi
	@docker system prune -a --volumes -f

## Full clean: containers, volumes, images and data
fclean: clean
	@echo "$(RED)Full cleanup...$(RESET)"
	@if grep -q '$(DOMAIN)' $(HOST_FILE); then \
		echo "$(YELLOW)Removing $(DOMAIN) from $(HOST_FILE)...$(RESET)"; \
		sudo sed -i '/$(DOMAIN)/d' $(HOST_FILE); \
	fi

## Rebuild environment from scratch
re: fclean all

## Show project information
info:
	@echo "\n$(CYAN)=== Project Information ===$(RESET)"
	@echo "User:       $(USER)"
	@echo "Domain:     $(DOMAIN)"
	@echo "Volumes:    $(VOLUME_PATH)"
	@echo "Containers:"
	@docker-compose -f $(COMPOSE_FILE) ps
