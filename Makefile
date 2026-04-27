TARGET = inception

CERT_PATH=./srcs/requirements/nginx/tools/certs

DATA_PATH 	= /home/$(shell whoami)/data
DB_PATH 		= $(DATA_PATH)/mariadb
WP_PATH 		= $(DATA_PATH)/wordpress

COMPOSE = docker compose -f ./srcs/compose.yaml

RED='\033[0;31m'
NC='\033[0m'

all: $(TARGET)

$(TARGET): up 

setup:
	@if [ ! -d $(DB_PATH) ] || [ ! -d $(WP_PATH) ]; then \
		mkdir -p $(DB_PATH); \
		mkdir -p $(WP_PATH); \
		echo "created directories for docker 'bind-mount-volumes' (in $(HOME)/data/)"; \
	fi
	@if [ ! -f ./secrets/db_password.txt ] || [ ! -f ./secrets/db_root_password.txt ] || [ ! -f ./secrets/wp_password.txt ]; then \
		mkdir -p ./secrets; \
		touch ./secrets/db_password.txt ./secrets/db_root_password.txt ./secrets/wp_password.txt; \
		echo "created empty secret-files (in ./secrets/)"; \
		echo ${RED}"The secrets still need to be set."${NC}; \
	fi
	@if [ ! -f ./srcs/.env ]; then \
		echo ${RED}"mv .env.example to .env and enter proper values."${NC}; \
	fi
	@if [ ! -f $(CERT_PATH)/server.key ] || [ ! -f $(CERT_PATH)/server.crt ]; then \
		echo "creating certificate:"; \
		mkdir -p $(CERT_PATH); \
		openssl req -x509 -quiet -newkey rsa:4096 -sha256 -nodes \
						-keyout $(CERT_PATH)/server.key \
						-out $(CERT_PATH)/server.crt \
						-days 365 \
						-subj "/CN=localhost"; \
		echo "created sll_certificates"; \
	fi

up: setup
	@if [ ! -s ./secrets/db_password.txt ] || [ ! -s ./secrets/db_root_password.txt ] || [ ! -s ./secrets/wp_password.txt ]; then \
		echo ${RED}"The secrets still need to be set."${NC}; \
		exit 1; \
	fi
	@if [ ! -f ./srcs/.env ]; then \
		echo ${RED}"mv .env.example to .env and enter proper values."${NC}; \
		exit 1; \
	fi
	@$(COMPOSE) up -d --build
	# $(COMPOSE) up -d

down:
	@$(COMPOSE) down

clean: down
	@echo "removing volumes and images"
	@$(COMPOSE) down -v --rmi all

fclean: clean
	@echo "removing all data, including secrets, cert-files and environment"
	@rm ./srcs/.env
	@rm ./secrets/*
	@rm -rf $(CERT_PATH)
	@sudo rm -rf $(DATA_PATH)
	@docker system prune -af

re: fclean all

.PHONY: all setup up down clean fclean re
