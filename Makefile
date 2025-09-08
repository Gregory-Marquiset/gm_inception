LOGIN      ?= gmarquis
DATA_DIR   ?= /home/$(LOGIN)/data
COMPOSE    := docker compose -f srcs/docker-compose.yml --env-file srcs/.env

WP_UID := 100
WP_GID := 101
WP_DIR := /home/$(LOGIN)/data/wordpress

IMAGES := inception-nginx:dev inception-wordpress:dev inception-mariadb:dev \
          adminer:dev redis:dev

.PHONY: all dirs up down restart ps logs clean fclean re sh-nginx sh-wp sh-db

all: dirs up

dirs:
	mkdir -p $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb $(DATA_DIR)/portainer

preperm:
	@sudo install -d -o $(WP_UID) -g $(WP_GID) -m 2775 $(WP_DIR)
	@sudo find $(WP_DIR) -type d -exec chmod 2775 {} \; || true
	@sudo find $(WP_DIR) -type f -exec chmod 0664 {} \; || true

up:
	docker compose -f srcs/docker-compose.yml --env-file srcs/.env up --build -d


down:
	$(COMPOSE) down

restart:
	$(COMPOSE) restart

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f

clean: down
	rm -rf $(DATA_DIR)/wordpress/* $(DATA_DIR)/mariadb/* $(DATA_DIR)/portainer/*

fclean: clean
	- docker image rm $(IMAGES) 2>/dev/null || true

re: fclean all

sh-nginx:
	$(COMPOSE) exec nginx sh || true
sh-wp:
	$(COMPOSE) exec wordpress sh || true
sh-db:
	$(COMPOSE) exec mariadb sh || true
