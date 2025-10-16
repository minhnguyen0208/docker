# Dockerized Laravel + Vite (Multi-Project Ready)

## 1) Edit .env
- PROJECT, DOMAIN
- APP_PATH, FE_PATH
- Ports (HTTP_PORT, VITE_PORT, MYSQL_PORT, REDIS_PORT)
- DB creds (DB_NAME, DB_USER, DB_PASS, DB_ROOT)

## 2) Hosts entry (macOS)
sudo sh -c 'echo "127.0.0.1 ${DOMAIN}" >> /etc/hosts'

## 3) Bring it up
make up
make init
make fe

- Open http://${DOMAIN} (or http://localhost if you keep DOMAIN as localhost)
- Vite: http://${DOMAIN}:${VITE_PORT}

## Nginx template
Using /etc/nginx/templates/default.conf.template with SERVER_NAME env.

## Notes
- Use Laravel DB_HOST=db in your app .env
- Nginx proxies PHP to 'app:9000' (compose service name)
- Exception for /public/localization.js is included
- Static files fall back to Laravel if missing
