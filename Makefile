.PHONY: all up down build

all: build up

build:
	docker-compose -f Srcs/docker-compose.yml build

up:
	docker-compose -f Srcs/docker-compose.yml up -d

down:
	docker-compose -f Srcs/docker-compose.yml down
