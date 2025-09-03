# ====== Config ======
LOGIN      ?= gmarquis
DATA_DIR   ?= /home/$(LOGIN)/data
COMPOSE    := docker compose -f srcs/docker-compose.yml --env-file srcs/.env

WP_UID := 100
WP_GID := 101
WP_DIR := /home/gmarquis/data/wordpress

IMAGES := inception-nginx:dev inception-wordpress:dev inception-mariadb:dev \
          adminer:dev redis:dev

# ====== Targets ======
.PHONY: all dirs up down restart ps logs clean fclean re sh-nginx sh-wp sh-db

all: dirs up        ## prépare les dossiers + up --build -d

dirs:               ## crée les répertoires persistants s'ils n'existent pas
	mkdir -p $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb

preperm:
	@sudo install -d -o $(WP_UID) -g $(WP_GID) -m 2775 $(WP_DIR)
	@sudo find $(WP_DIR) -type d -exec chmod 2775 {} \; || true
	@sudo find $(WP_DIR) -type f -exec chmod 0664 {} \; || true

up:
	docker compose -f srcs/docker-compose.yml --env-file srcs/.env up --build -d


down:               ## stop + retire les conteneurs
	$(COMPOSE) down

restart:            ## restart des services
	$(COMPOSE) restart

ps:                 ## état des services
	$(COMPOSE) ps

logs:               ## logs suivis
	$(COMPOSE) logs -f

clean: down         ## vide les données (⚠️ persistance WP/DB)
	rm -rf $(DATA_DIR)/wordpress/* $(DATA_DIR)/mariadb/*

fclean: clean       ## supprime aussi les images locales (laisse le cache builder)
	- docker image rm $(IMAGES) 2>/dev/null || true

re: fclean all      ## rebuild complet

sh-nginx:
	$(COMPOSE) exec nginx sh || true
sh-wp:
	$(COMPOSE) exec wordpress sh || true
sh-db:
	$(COMPOSE) exec mariadb sh || true
