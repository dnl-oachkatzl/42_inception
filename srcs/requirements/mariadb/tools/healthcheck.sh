#!/bin/bash

export MYSQL_PWD="$(cat /run/secrets/db_root_password)"

exec mariadb-admin ping \
        -h localhost \
        -u root \
        -e "SELECT 1"
