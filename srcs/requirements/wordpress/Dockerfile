# php 8.2 !!!

FROM debian:bookworm

RUN apt update && \
    apt install -y \
                    php \
                    php-cli \
                    php-fpm \
                    php-mysql \
                    php-xml \
                    php-gd \
                    php-curl \
                    php-zip \
                    php-mbstring \
                    curl less mariadb-client unzip && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp
    # mv wp-cli.phar /usr/local/bin/wp

# RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
# RUN chmod +x /usr/local/bin/wp

# php-fpm config : listening to port 9000
COPY tools/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000

CMD ["entrypoint.sh"]

