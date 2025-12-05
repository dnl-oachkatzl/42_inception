
RED='\033[0;31m'
NC='\033[0m'

up:
	docker compose -f ./srcs/compose.yaml up

down:
	docker compose -f ./srcs/compose.yaml down

set-up:
	-mkdir $(HOME)/data/database
	touch ./secrets/db_password.txt ./secrets/db_root_password.txt ./secrets/wp_password.txt
	@echo -e ${RED}These secrets still need to be set.${NC}
	@echo test

deconst_vol:
	rm -r $(HOME)/data/database/*
