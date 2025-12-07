FROM debian:bookworm

RUN apt update && apt install -y nginx openssl &&\
    apt clean && \
    rm -rf /var/lib/apt/lists/*
# RUN apt install -y procps

# COPY ./tools/nginx.conf /etc/nginx/nginx.conf
# COPY ./tools/certs/ /etc/nginx/certs/
COPY ./tools/ /etc/nginx/

EXPOSE 443
# EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
