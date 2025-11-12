LOGIN      ?= gmarquis
DATA_DIR   ?= /home/$(LOGIN)/data
COMPOSE    := docker compose -f srcs/docker-compose.yml --env-file srcs/.env
UID := $(shell id -u)
GID := $(shell id -g)

.PHONY: all dirs up fix-perms down clean fclean re

all: dirs up fix-perms

dirs:
	mkdir -p $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb $(DATA_DIR)/portainer

up:
	docker compose -f srcs/docker-compose.yml --env-file srcs/.env up --build -d

fix-perms:
	docker run --rm -v $(DATA_DIR)/mariadb:/data alpine sh -lc "chown -R $(UID):$(GID) /data"
	docker run --rm -v $(DATA_DIR)/wordpress:/data alpine sh -lc 'chown -R $(UID):$(GID) /data'

down:
	$(COMPOSE) down

show:
	- docker ps -a
	- docker image ls
	- docker volume ls
	- docker network ls
	- ls -l $(DATA_DIR)

clean: down
	rm -rf $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress $(DATA_DIR)/portainer

fclean: clean
	- docker ps -aq | xargs -r docker rm -f
	- docker images -q | xargs -r docker rmi -f
	- docker volume ls -q | xargs -r docker volume rm -f
	- docker system prune -a --volumes -f

re: fclean all