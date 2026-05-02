FROM debian:bookworm

RUN apt update && apt install -y nginx openssl &&\
    apt clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./tools/ /etc/nginx/

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
