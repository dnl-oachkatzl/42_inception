CERT_PATH=./srcs/requirements/nginx/tools/certs

RED='\033[0;31m'
NC='\033[0m'

up:
	docker compose -f ./srcs/compose.yaml up --build

down:
	docker compose -f ./srcs/compose.yaml down

set-up:
	@mkdir -p $(CERT_PATH)
	@openssl req -x509 -quiet -newkey rsa:4096 -sha256 -nodes \
					-keyout $(CERT_PATH)/server.key \
					-out $(CERT_PATH)/server.crt \
					-days 365 \
					-subj "/CN=localhost"
	@mkdir -p $(HOME)/data/database
	@touch ./secrets/db_password.txt ./secrets/db_root_password.txt ./secrets/wp_password.txt
	@echo "created sll_certificates, directories for docker 'bind-mount-volumes' (in $(HOME)/data/) and secret-files (in ./secrets/)"
	@echo ${RED}"The secrets still need to be set."${NC}
	@echo ${RED}"mv .env.example to .env and enter proper values."${NC}

deconst_vol:
	rm -r $(HOME)/data/database
