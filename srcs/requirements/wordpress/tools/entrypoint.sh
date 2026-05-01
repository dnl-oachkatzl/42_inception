#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

WP_DIR=/var/www/wordpress


log() {
  echo "[wordpress] $*";
}

# download wordpress if not present
if [ ! -f "${WP_DIR}/wp-login.php" ]; then
  log "downloading wordpress..."
  wp core download \
    --path="${WP_DIR}" \
    --allow-root
  log "finished downloading wordpress"
fi

# configure wordpress if not alreadz done
if [ ! -f "${WP_DIR}/wp-config.php" ]; then
  log "configuring wordpress..."
  wp config create \
    --path="${WP_DIR}" \
    --dbname="${WP_DB_NAME}" \
    --dbuser="${WP_DB_USER}" \
    --dbpass="${DB_PASSWORD}" \
    --dbhost="${WP_DB_HOST}" \
    --dbcharset="utf8mb4" \
    --skip-check \
    --allow-root

  echo "done configuring wordpress"
fi

# waiting for mariadb server
log "waiting for mariadb..."
until wp db check --path="${WP_DIR}" --allow-root 2>/dev/null; do
  sleep 2
done
log "mariadb is ready"

# installing wordpress
if ! wp core is-installed --path="${WP_DIR}" --allow-root 2>/dev/null; then
  log "running wp core install..."
  wp core install \
    --path="${WP_DIR}" \
    --url="https://${DOMAIN_NAME}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --skip-email \
    --allow-root

  log "creating regular user: ${WP_USER}"
  wp user create \
    "${WP_USER}" \
    "${WP_USER_EMAIL}" \
    --user_pass="${WP_USER_PASSWORD}" \
    --path="${WP_DIR}" \
    --allow-root

  log "installation complete"
fi

chown -R www-data:www-data ${WP_DIR}

log "starting php-fpm..."

exec php-fpm8.2 -F
