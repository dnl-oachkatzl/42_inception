*This project has been created as part of the 42 curriculum by daspring.*

# Inception

## Description

**Inception** is a system administration project that teaches Docker containerisation by building a small but complete web infrastructure from scratch. Every service runs in its own dedicated container, all images are built from custom Dockerfiles (no pre-built images from DockerHub), and the whole stack is orchestrated with Docker Compose.

The final infrastructure exposes a WordPress site over HTTPS (TLSv1.2/1.3 only) and consists of three containers communicating over a private Docker network:

```
Internet
   │  HTTPS :443
   ▼
┌──────────────────────────────────────────────┐
│  Docker network (inception_net)              │
│                                              │
│  [NGINX] ──:9000──► [WordPress+php-fpm]      │
│                            │ :3306           │
│                      [MariaDB]               │
└──────────────────────────────────────────────┘
```

---

## Project Description

### Docker in this project

Each service (NGINX, WordPress+php-fpm, MariaDB) lives in its own container built from a custom Dockerfile based on Debian Bookworm. A `docker-compose.yml` file declares all services, volumes, secrets, and the network. The `Makefile` at the root automates building and running the whole stack.

### Virtual Machines vs Docker

| | Virtual Machine | Docker Container |
|---|---|---|
| **Isolation** | Full OS virtualisation (hypervisor) | Process-level isolation (namespaces + cgroups) |
| **Startup time** | Minutes | Seconds |
| **Size** | GBs (full OS image) | MBs (only what the app needs) |
| **Overhead** | High (emulates hardware) | Low (shares host kernel) |
| **Use case** | Full OS isolation, legacy apps. cyberSec | Microservices, reproducible builds |

Docker is not a VM. Containers share the host kernel — they are isolated processes, not full machines.

### Secrets vs Environment Variables

| | Docker Secrets | Environment Variables |
|---|---|---|
| **Storage** | Mounted as a file at `/run/secrets/<n>` | In process environment |
| **Visibility** | Not in `docker inspect`, not in logs | Visible in `docker inspect` |
| **Scope** | Only available to services that declare them | Available to the whole container |
| **Security** | Safer for passwords and API keys | Suitable for non-sensitive config, might leak |

This project uses **Docker secrets** for all passwords (DB password, root password, WP admin and user passwords). Non-sensitive config (database name, domain name, usernames) lives in `.env`.

### Docker Network vs Host Network

| | Docker Network (bridge) | Host Network |
|---|---|---|
| **Isolation** | Containers get their own virtual network | Container shares host's network stack |
| **Security** | Containers only see each other if connected | Full access to host interfaces |
| **Port mapping** | Explicit (`ports:` in compose) | No mapping needed |
| **Subject** | **Required** — `network: host` is forbidden | Forbidden by the subject |

We use a custom `bridge` network called `inception_net`. Only NGINX has a host-facing port (`443`). MariaDB and WordPress are invisible from outside.

### Docker Volumes vs Bind Mounts

| | Docker Named Volumes | Bind Mounts |
|---|---|---|
| **Managed by** | Docker daemon | You (host path) |
| **Portability** | Docker manages the path | Tied to a specific host path |
| **Subject** | **Required** for the two data volumes | **Forbidden** for the two data volumes |
| **Data location** | Configured via `driver_opts` to `/home/<login>/data/` | Arbitrary host path |

The project uses two named volumes: `mariadb_data` and `wordpress_data`. Both are configured to store data at `/home/<login>/data/` on the host machine.

---

## Instructions

### Prerequisites

- A Virtual Machine running Linux (Debian/Ubuntu recommended)
- Docker Engine and Docker Compose v2 installed
- `make` installed

### 1. Clone the repository

```bash
git clone <your-repo-url> inception
cd inception
```

### 2. Add the domain to `/etc/hosts`

```bash
echo "127.0.0.1  yourlogin.42.fr" | sudo tee -a /etc/hosts
```
or
```bash
vim /etc/hosts
```

### 3. Set up context for docker compose
#### run make setup
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

### 5. Build and start

```bash
make
```

This will:
- Build all three Docker images from their Dockerfiles
- Start the full stack in the background

### 6. Access the site

Open your browser and navigate to: `https://yourlogin.42.fr`

Accept the self-signed certificate warning. The WordPress site will be ready.

### Useful commands

```bash
make down    # Stop and remove containers (data preserved)
make clean   # Stop, remove containers, volumes, and images
make fclean  # Full cleanup including host data directories
make re      # Full rebuild from scratch
```

---

## Resources

### Docker & containerisation
- [Docker official documentation](https://docs.docker.com/)

### NGINX & TLS
- [NGINX documentation](https://nginx.org/en/docs/)
### WordPress & php-fpm
- [WP-CLI documentation](https://wp-cli.org/)
- [php-fpm configuration](https://www.php.net/manual/en/install.fpm.configuration.php)

### MariaDB
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)

### AI usage in this project

AI (Claude) was used for the following tasks:
- **Debugging**: Suggesting fixes for MariaDB socket/TCP binding issues.
- **Documentation**: Writing these reviewed readmes
