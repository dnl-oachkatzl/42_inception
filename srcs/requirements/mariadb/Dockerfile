FROM debian:bookworm

RUN apt update && \
    apt install -y mariadb-server mariadb-client && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/lib/mysql/*

COPY tools/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY tools/healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

EXPOSE 3306

CMD ["docker-entrypoint.sh"]
