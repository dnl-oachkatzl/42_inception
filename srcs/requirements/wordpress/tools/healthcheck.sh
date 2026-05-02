#!/bin/bash

WP_DIR=/var/www/wordpress

# check if fpm is listening
if ! cgi-fcgi -bind -connect localhost:9000 > /dev/null 2>&1; then
    echo "php-fpm not responding"
    exit 1
fi

#check if wordpress in configured
if [ ! -f "${WP_DIR}/wp-config.php" ]; then
    echo "wordpress not yet configured"
    exit 1
fi

exit 0