#!/bin/bash
set -e

DATA_PATH="/var/lib/mysql"

MARIADB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MARIADB_PASSWORD=$(cat /run/secrets/db_password)

log() {
	echo "[entrypoint] $*"
}
 
database_exists() {
	[ -d "$DATA_PATH/mysql" ]
}

initialize_database() {
	# touch "$DATA_PATH/mysql/.exists"
    log "initializing MariaDB for the first time..."

    mariadb-install-db \
        --user=mysql \
        --datadir="$DATA_PATH"


    log "starting temporary MariaDB server..."
    
    mariadbd \
        --user=mysql \
        --datadir="$DATA_PATH" \
        --skip-networking \
        --socket=/tmp/mysqld.sock &
    pid="$!"

    log "waiting for MariaDB to bcome ready..."
    
    until mariadb-admin \
        --socket=/tmp/mysqld.sock \
        ping \
        --silent; do
        sleep 1
    done
    
    log "initializing..."


    mariadb --socket=/tmp/mysqld.sock <<EOF
    	-- set root password
    	ALTER USER 'root'@'localhost'
    		IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
    	
	-- create wordpress database
	CREATE DATABASE IF NOT EXISTS ${MARIADB_DATABASE}
		CHARACTER SET utf8mb4
		COLLATE utf8mb4_general_ci;
	
	-- create wordpress user
	CREATE USER '${MARIADB_USER}'@'%'
		IDENTIFIED BY '${MARIADB_PASSWORD}';
	
	GRANT ALL PRIVILEGES
		ON ${MARIADB_DATABASE}.*
		TO '${MARIADB_USER}'@'%';
	
	FLUSH PRIVILEGES;
EOF
    
    log "shutting down temporary server..."
    
    mariadb-admin \
        --socket=/tmp/mysqld.sock \
        --user=root \
        --password="${MARIADB_ROOT_PASSWORD}" \
        shutdown
	wait "$pid"

    log "MariaDB initialization complete."
}

main() {
	log "container startup"
	
   	mkdir -p /run/mysqld
    	chown mysql:mysql /run/mysqld
    	
	if database_exists; then
		log "existing database found. skipping initialization."
	else
		chown -R mysql:mysql "$DATA_PATH"
		initialize_database
	fi
	
	log "starting mariadb server..."
	
	exec mariadbd \
		--user=mysql \
		--datadir="$DATA_PATH" \
    		--bind-address=0.0.0.0 \
		--console
}

main
