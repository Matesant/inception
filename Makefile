#------------------------------------------------------------------------------#
#                                VARIABLES                                     #
#------------------------------------------------------------------------------#

USER            =   $(shell whoami)
VOLUME_PATH     =   /home/$(USER)/data
WORDPRESS_PATH  =   $(VOLUME_PATH)/wordpress
MARIADB_PATH    =   $(VOLUME_PATH)/mariadb
MYSQLD_RUN_PATH =   $(VOLUME_PATH)/mysqld_run
HOST_FILE       =   /etc/hosts
DOMAIN          =   $(USER).42.fr
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

## Inicia os containers
up:
	@echo "$(CYAN)Starting containers...$(RESET)"
	@docker-compose -f $(COMPOSE_FILE) --env-file $(DOT_ENV_FILE) up -d --build

## Para os containers
down:
	@echo "$(RED)Stopping containers...$(RESET)"
	@docker-compose -f $(COMPOSE_FILE) down

## Configura o ambiente
setup:
	@echo "$(GREEN)Setting up environment...$(RESET)"
	@sudo mkdir -p $(WORDPRESS_PATH) $(MARIADB_PATH) $(MYSQLD_RUN_PATH)
	@sudo chown -R $(USER):$(USER) $(WORDPRESS_PATH) $(MARIADB_PATH) $(MYSQLD_RUN_PATH)
	@sudo chmod -R 777 /home/$(USER)/data
	@if ! grep -q '$(DOMAIN)' $(HOST_FILE); then \
		echo "$(YELLOW)Adding $(DOMAIN) to $(HOST_FILE)...$(RESET)"; \
		sudo sh -c 'echo "127.0.0.1\t$(DOMAIN)" >> $(HOST_FILE)'; \
	fi
	@if [ ! -f "$(DOT_ENV_FILE)" ]; then \
		echo "$(YELLOW)Creating .env file...$(RESET)"; \
		echo "DOMAIN_NAME=$(DOMAIN)" > $(DOT_ENV_FILE); \
		echo "MYSQL_ROOT_PASSWORD=rootpass" >> $(DOT_ENV_FILE); \
		echo "MYSQL_PASSWORD=userpass" >> $(DOT_ENV_FILE); \
	fi

## Limpa containers e networks
clean: down
	@echo "$(RED)Cleaning Docker resources...$(RESET)"
	@docker system prune -f

## Limpeza completa (containers, volumes, imagens)
fclean: clean
	@echo "$(RED)Full cleanup...$(RESET)"
	@docker system prune -af --volumes
	@sudo rm -rf $(VOLUME_PATH)/*
	@if grep -q '$(DOMAIN)' $(HOST_FILE); then \
		sudo sed -i '/$(DOMAIN)/d' $(HOST_FILE); \
	fi

## Reinicia completamente o ambiente
re: fclean all

## Mostra informações úteis
info:
	@echo "\n$(CYAN)=== Project Information ===$(RESET)"
	@echo "User: $(USER)"
	@echo "Domain: $(DOMAIN)"
	@echo "Data volumes: $(VOLUME_PATH)"
	@echo "Containers status:"
	@docker-compose -f $(COMPOSE_FILE) ps