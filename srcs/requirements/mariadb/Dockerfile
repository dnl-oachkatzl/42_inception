FROM debian:bookworm

RUN apt update && \
    apt install -y mariadb-server mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# MariaDB soll nicht im Hintergrund laufen
# RUN sed -i 's/^daemonize\s*=.*/daemonize = 0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# Skript für Initialisierung + Start
COPY ./tools/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["mysqld", "--user=mysql", "--bind-address=0.0.0.0"]
# CMD ["bash"]
