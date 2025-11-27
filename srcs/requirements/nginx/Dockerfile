FROM debian:bookworm

RUN apt update && apt install -y nginx
RUN apt install -y procps

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
