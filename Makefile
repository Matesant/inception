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
	@docker-compose -f $(COMPOSE_FILE) --env-file $(DOT_ENV_FILE) up -d --build

## Stop containers
down:
	@echo "$(RED)Stopping containers...$(RESET)"
	@docker-compose -f $(COMPOSE_FILE) down

## Set up environment: folders, .env, hosts
setup:
	@echo "$(GREEN)Setting up environment...$(RESET)"
	@sudo mkdir -p $(WORDPRESS_PATH) $(MARIADB_PATH) $(MYSQLD_RUN_PATH)
	@sudo chown -R $(USER):$(USER) $(VOLUME_PATH)
	@sudo chmod -R 755 $(VOLUME_PATH)
	@if ! grep -q '$(DOMAIN)' $(HOST_FILE); then \
		echo "$(YELLOW)Adding $(DOMAIN) to $(HOST_FILE)...$(RESET)"; \
		echo "127.0.0.1	$(DOMAIN)" | sudo tee -a $(HOST_FILE); \
	fi
	@if [ ! -f "$(DOT_ENV_FILE)" ]; then \
		echo "$(YELLOW)Creating .env file...$(RESET)"; \
		echo "DOMAIN_NAME=$(DOMAIN)" > $(DOT_ENV_FILE); \
		echo "MYSQL_ROOT_PASSWORD=rootpass" >> $(DOT_ENV_FILE); \
		echo "MYSQL_DATABASE=wordpress" >> $(DOT_ENV_FILE); \
		echo "MYSQL_USER=wp_user" >> $(DOT_ENV_FILE); \
		echo "MYSQL_PASSWORD=userpass" >> $(DOT_ENV_FILE); \
		echo "WORDPRESS_DB_HOST=mariadb" >> $(DOT_ENV_FILE); \
		echo "WORDPRESS_DB_NAME=wordpress" >> $(DOT_ENV_FILE); \
		echo "WORDPRESS_DB_USER=wp_user" >> $(DOT_ENV_FILE); \
		echo "WORDPRESS_DB_PASSWORD=userpass" >> $(DOT_ENV_FILE); \
	fi

## Clean containers and networks
clean: down
	@echo "$(RED)Cleaning Docker resources...$(RESET)"
	@docker system prune -f

## Full clean: containers, volumes, images and data
fclean: clean
	@echo "$(RED)Full cleanup...$(RESET)"
	@docker system prune -af --volumes
	@sudo rm -rf $(VOLUME_PATH) 2>/dev/null || true
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
