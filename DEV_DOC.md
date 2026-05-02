# DEV_DOC.md — Developer Documentation

## Setting up the environment from scratch

### Prerequisites

Install the following on your Virtual Machine:

```bash
# Docker Engine (Debian/Ubuntu)
sudo apt update
sudo apt install -y docker.io docker-compose git make

# Allow your user to run docker without sudo
sudo usermod -aG docker $USER
newgrp docker
```

### Repository structure

```
inception/
├── Makefile                        ← Build entrypoint
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/                        ← Secret files (NEVER commit real values!)
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└── srcs/
    ├── .env                        ← Non-secret config (safe to commit)
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   └── tools/
        |       ├── nginx.conf
        │       └── certs/
        │           ├── server.crt
        │           └── server.key
        ├── wordpress/
        │   ├── Dockerfile
        │   └── tools
        │       ├── www.conf
        │       └── docker-entrypoint.sh
        └── mariadb/
            ├── Dockerfile
            └── tools/docker-entrypoint.sh
```

### Configuration files

**`srcs/.env`** — Non-sensitive environment variables loaded by Docker Compose.  
Edit `DOMAIN_NAME`, `WP_ADMIN_USER`, `WP_ADMIN_EMAIL`, `WP_USER`, `WP_USER_EMAIL`, `WP_TITLE`, ...

**`secrets/*.txt`** — One password per file, no trailing whitespace recommended.  
These files are read at container startup by the entrypoint scripts via `cat /run/secrets/<name>`.

### Domain name setup

```bash
# Add to /etc/hosts on your VM (and host machine if browsing from host)
echo "127.0.0.1  <yourlogin>.42.fr" | sudo tee -a /etc/hosts
```
or have a proper look at it:
```bash
vim /etc/hosts
```

---

## Building and launching with Makefile and Docker Compose

### First build

### Set up context for docker compose
``` bash
make setup
```

This will:
- Created token secret files
- Create `/home/<login>/data/mariadb` and `/home/<login>/data/wordpress`
- Create a self-sgned SSL certificate for nginx 

#### Make .env available

Copy `srcs/.env.example` to `srcs/.env` and set all values:

#### Create the secret files

Fill in the four secret files with strong passwords (do NOT commit real passwords):

```bash
echo "MyStr0ngDbPass!"    > secrets/db_password.txt
echo "MyStr0ngRootPass!"  > secrets/db_root_password.txt
echo "MyStr0ngAdminPass!" > secrets/wp_admin_password.txt
echo "MyStr0ngUserPass!"  > secrets/wp_user_password.txt
```

### Build and start

```bash
make
```

This will:
- Build all three Docker images from their Dockerfiles
- Start the full stack in the background

### Rebuild a single service

```bash
docker compose -f srcs/docker-compose.yml build wordpress
docker compose -f srcs/docker-compose.yml up -d --no-deps wordpress
```

### Full rebuild from scratch

```bash
make re    # runs fclean then all
```

---

## Managing containers and volumes

### Useful Docker Compose commands

```bash
# Run all from srcs/ or prefix with -f srcs/docker-compose.yml

# See container status
docker compose -f srcs/docker-compose.yml ps

# Follow all logs
docker compose -f srcs/docker-compose.yml logs -f

# Shell into a running container
docker exec -it nginx bash
docker exec -it wordpress bash
docker exec -it mariadb bash

# Restart one service
docker compose -f srcs/docker-compose.yml restart wordpress

# Stop everything without removing
docker compose -f srcs/docker-compose.yml stop

# Remove containers but keep volumes
docker compose -f srcs/docker-compose.yml down

# Remove containers AND volumes (WARNING: data loss!)
docker compose -f srcs/docker-compose.yml down -v
```

### Inspect Docker secrets (confirm they are mounted correctly)

```bash
docker exec -it wordpress ls /run/secrets/
# Should list: db_password  wp_admin_password  wp_user_password

docker exec -it mariadb cat /run/secrets/db_password
# Should print the password from secrets/db_password.txt
```

### Inspect the Docker network

```bash
docker network ls
docker network inspect inception_srcs_inception_net
```

---

## Data storage and persistence

### Where data lives

| Volume name | Host path | Container path | Purpose |
|---|---|---|---|
| `mariadb_data` | `/home/<login>/data/mariadb` | `/var/lib/mysql` | MariaDB database files |
| `wordpress_data` | `/home/<login>/data/wordpress` | `/var/www/wordpress` | WordPress PHP files + uploads |

The host paths are configured in `docker-compose.yml` using `driver_opts`:

```yaml
volumes:
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/${HOST_LOGIN}/data/mariadb
```

This means:
- Data persists across container restarts and even `docker compose down`
- Data is only lost if you run `make fclean` (which runs `sudo rm -rf /home/<login>/data`)


---

## How Docker Secrets work in this project

Docker secrets are the secure way to pass sensitive data to containers. Here is the flow:

```
secrets/db_password.txt          (on host, not in image, not in env)
         │
         │  docker-compose mounts it as a tmpfs file
         ▼
/run/secrets/db_password         (inside container, read-only)
         │
         │  entrypoint script reads it
         ▼
DB_PASSWORD=$(cat /run/secrets/db_password)
         │
         │  used in mysqld setup SQL / wp config create
         ▼
Never appears in: docker inspect, process list, image layers, logs
```

This is strictly more secure than:
```yaml
# BAD — visible in docker inspect and process environment:
environment:
  MYSQL_PASSWORD: mysecretpassword
```
