# USER_DOC.md — User & Administrator Documentation

## What services does this stack provide?

The Inception stack runs three services inside Docker containers:

| Service | Purpose | Accessible from outside? |
|---|---|---|
| **NGINX** | Reverse proxy + TLS termination | Yes — `https://<login>.42.fr` (port 443) |
| **WordPress + php-fpm** | CMS web application | No — internal only (port 9000) |
| **MariaDB** | Relational database for WordPress | No — internal only (port 3306) |

Only NGINX is reachable from your browser. WordPress and MariaDB communicate exclusively over the private Docker network.

---

## Starting and stopping the project

### Start everything

```bash
# From the root of the repository:
make
```

This builds the images (first time only) and starts all containers in the background.

### Stop everything (containers only, data is kept)

```bash
make down
```

---

## Accessing the website and the administration panel

### Public website

Open your browser and go to:

```
https://<yourlogin>.42.fr
```

You will see a security warning about the self-signed certificate — this is expected for a local development setup. Click **"Advanced"** → **"Accept the Risk and Continue"** (Firefox) or **"Proceed anyway"** (Chrome).

### WordPress administration panel

```
https://<yourlogin>.42.fr/wp-admin
```

Log in with the **admin credentials** you set in `secrets/wp_admin_password.txt` and the `WP_ADMIN_USER` value in `srcs/.env`.

---

## Credentials — where to find them and how to manage them

All sensitive credentials are stored as **Docker secrets** in plain text files inside the `secrets/` directory at the root of the repository. This directory must be added to `.gitignore` so passwords are never committed to version control.

| Secret file | What it contains |
|---|---|
| `secrets/db_password.txt` | MariaDB password for the WordPress user |
| `secrets/db_root_password.txt` | MariaDB root password |
| `secrets/wp_admin_password.txt` | WordPress admin account password |
| `secrets/wp_user_password.txt` | WordPress regular user account password |

Non-sensitive configuration (usernames, database name, domain) is in `srcs/.env`.

To change a password after first setup:
1. Update the relevant file in `secrets/`
2. Run `make re` to rebuild and re-initialise (this wipes data — back up first!)

---

## Checking that services are running correctly

### Quick status overview

```bash
make ps
```

All three containers (`nginx`, `wordpress`, `mariadb`) should show status `Up`.

### Logs for a specific service

```bash
docker compose -f srcs/docker-compose.yml logs -f my_nginx
docker compose -f srcs/docker-compose.yml logs -f my_wordpress
docker compose -f srcs/docker-compose.yml logs -f my_mariadb
```

### Check the HTTPS connection

```bash
curl -k https://<yourlogin>.42.fr
```

You should see WordPress HTML output.

### Check MariaDB from inside the container

```bash
docker exec -it my_mariadb mysql -u root -p wordpress
# Enter the password from secrets/db_password.txt
# -u <username> is defined in .env - may differ.
```

### Verify TLS version

```bash
openssl s_client -connect yourlogin.42.fr:443 -tls1_2
# Should succeed (TLSv1.2 allowed)

openssl s_client -connect yourlogin.42.fr:443 -tls1
# Should fail (TLSv1.0 forbidden)
```
