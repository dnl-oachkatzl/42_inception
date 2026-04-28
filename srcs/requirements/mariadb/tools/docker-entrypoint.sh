#!/bin/bash
set -e

DATA_PATH="/var/lib/mysql"

MARIADB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MARIADB_PASSWORD=$(cat /run/secrets/db_password)

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql "$DATA_PATH"

if [ ! -f "$DATA_PATH/.initialized" ]; then
    echo "Initializing MariaDB for the first time..."

    mariadb-install-db \
        --user=mysql \
        --datadir="$DATA_PATH"

    echo "Starting temporary MariaDB server..."

    mysqld --user=mysql --datadir="$DATA_PATH" --skip-networking &
    pid="$!"

    until mysqladmin ping --silent; do
        sleep 1
    done

    mysql -u root <<EOF
ALTER USER 'root'@'localhost'
IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';

CREATE DATABASE ${MARIADB_DATABASE}
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

CREATE USER '${MARIADB_USER}'@'%'
IDENTIFIED BY '${MARIADB_PASSWORD}';

GRANT ALL PRIVILEGES
ON ${MARIADB_DATABASE}.*
TO '${MARIADB_USER}'@'%';

FLUSH PRIVILEGES;
EOF

    mysqladmin -u root shutdown

    touch "$DATA_PATH/.initialized"

    echo "MariaDB initialization complete."
fi

exec "$@"
