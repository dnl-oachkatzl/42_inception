#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

WP_DIR=/var/www/wordpress

# download wordpress if not present
if [ ! -f "${WP_DIR}/wp-login.php" ]; then
  echo "downloading wordpress..."
  wp core download \
    --path="${WP_DIR}" \
    --allow-root
  echo "finished downloading wordpress"
fi

# configure wordpress if not alreadz done
# if [ ! -f "${WP_DIR}/wp-config.php" ]; then
#   echo "configuring wordpress..."
#   wp config create \
#     --path="${WP_DIR}" \
#     --allow-root
#
#   echo "done configuring wordpress"
# fi

chown -R www-data:www-data ${WP_DIR}

exec php-fpm8.2 -F
