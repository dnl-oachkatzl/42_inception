FROM debian:bookworm

RUN apt update && \
    apt install -y php php-cli php-fpm php-mysql php-xml \
                  php-gd php-curl php-zip php-mbstring \
                  curl less mariadb-client unzip && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar &&\
    chmod +x /usr/local/bin/wp

CMD ["bash"]

