COMPOSE = docker-compose -f src/docker-compose.yml --env-file src/.env

all: up

up:
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

re: down up

fclean: down
	docker system prune -af --volumes

.PHONY: all up down re fclean