#!/bin/bash
set -e

DATA_PATH="/var/lib/mysql"
MARIADB_ROOT_PASSWORD=$(cat "${MARIADB_ROOT_PASSWORD_FILE}")
MARIADB_PASSWORD=$(cat "${MARIADB_PASSWORD_FILE}")

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

if [ ! -f "$DATA_PATH/mysql/initialized" ]; then
  echo "initializing MariaDB for the first time"
  mysql_install_db --user=mysql --datadir="$DATA_PATH"
  mysqld --user=mysql --bootstrap <<EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
CREATE DATABASE $MARIADB_DATABASE CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';
FLUSH PRIVILEGES;
EOF
  touch $DATA_PATH/mysql/initialized
  echo "initialization complete"
else
  echo "database has already been initialized"
fi

exec "$@"
