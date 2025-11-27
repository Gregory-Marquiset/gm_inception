LOGIN      ?= gmarquis
DATA_DIR   ?= /home/$(LOGIN)/data
COMPOSE    := docker compose -f srcs/docker-compose.yml --env-file srcs/.env

.PHONY: all dirs up up-build build build-nocache down clean fclean re

all: dirs up

dirs:
	mkdir -p $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb

build: dirs
	$(COMPOSE) build

build-nocache: dirs
	$(COMPOSE) build --no-cache

up: build dirs
	$(COMPOSE) up -d

up-build: dirs
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

show:
	- docker ps -a
	- docker image ls
	- docker volume ls
	- docker network ls
	- ls -l $(DATA_DIR)

clean: down
	rm -rf $(DATA_DIR)/*

fclean: clean
	- docker ps -aq | xargs -r docker rm -f
	- docker images -q | xargs -r docker rmi -f
	- docker volume ls -q | xargs -r docker volume rm -f
	- docker system prune -a --volumes -f

re: fclean all
