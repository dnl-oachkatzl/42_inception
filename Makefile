up:
	docker compose -f ./srcs/compose.yaml up

down:
	docker compose -f ./srcs/compose.yaml down

set-up:
	mkdir $(HOME)/data/database
	touch ./secrets/db_password.txt ./secrets/db_root_password.txt ./secrets/wp_password.txt

deconst_vol:
	rm -r $(HOME)/data/database/*
