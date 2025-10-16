# ---- base ----
FROM php:8.3-fpm-alpine AS base

RUN set -eux; \
    # Runtime libs\
    apk add --no-cache \
    bash git curl \
    icu-libs libzip zlib \
    libpng freetype libjpeg-turbo \
    oniguruma libxml2 \
    openssl; \
    # Build deps for docker-php-ext-* and pecl \
    apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS build-base autoconf \
    icu-dev libzip-dev zlib-dev \
    libpng-dev freetype-dev libjpeg-turbo-dev \
    oniguruma-dev libxml2-dev \
    openssl-dev; \
    # Configure/compile PHP extensions\
    docker-php-ext-configure gd --with-freetype --with-jpeg; \
    docker-php-ext-install -j"$(nproc)" \
    pdo pdo_mysql mbstring zip intl xml gd ftp; \
    # PECL redis \
    pecl install -o -f redis && docker-php-ext-enable redis;         \
    # Clean up\
    apk del .build-deps


WORKDIR /var/www/html
ENV COMPOSER_ALLOW_SUPERUSER=1
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# --- New Relic PHP agent (Alpine) ---
# Provide these at build time:
#   --build-arg NEW_RELIC_USER_KEY=... (User API key, NOT ingest/License)
#   --build-arg NEW_RELIC_ACCOUNT_ID=...
#   --build-arg NEW_RELIC_LICENSE_KEY=...
# Optional:
#   --build-arg NEW_RELIC_APP_NAME=laravel-app
ARG NEW_RELIC_USER_KEY='NRAK-ZSZD1LP13FPH1Z30P9HQEAWDR5V'
ARG NEW_RELIC_ACCOUNT_ID=7131140
ARG NEW_RELIC_LICENSE_KEY='67e963e296a053a1c059558057fc28d8FFFFNRAL'
ARG NEW_RELIC_APP_NAME='skynet-7131140-1'
ENV NEW_RELIC_DAEMON_ADDRESS=@newrelic

RUN set -eux; \
  apk add --no-cache ca-certificates curl bash; \
  curl -fsSL https://download.newrelic.com/php_agent/release/newrelic-php5-12.1.0.26-linux-musl.tar.gz -o /tmp/nr-php-musl.tgz; \
  tar -xzf /tmp/nr-php-musl.tgz -C /tmp; \
  cd /tmp/newrelic-php5-*; \
  NR_INSTALL_USE_CP_NOT_LN=1 \
  NR_INSTALL_SILENT=true \
  NR_INSTALL_KEY="${NEW_RELIC_LICENSE_KEY}" \
  ./newrelic-install install; \
  ini="/usr/local/etc/php/conf.d/newrelic.ini"; \
  # Ensure license & appname are set (idempotent replace or append) \
  if grep -qE '^\s*newrelic\.license\s*=' "$ini"; then \
    sed -i -E "s#^\s*newrelic\.license\s*=.*#newrelic.license = ${NEW_RELIC_LICENSE_KEY}#g" "$ini"; \
  else echo "newrelic.license = ${NEW_RELIC_LICENSE_KEY}" >> "$ini"; fi; \
  if grep -qE '^\s*newrelic\.appname\s*=' "$ini"; then \
    sed -i -E "s#^\s*newrelic\.appname\s*=.*#newrelic.appname = ${NEW_RELIC_APP_NAME}#g" "$ini"; \
  else echo "newrelic.appname = ${NEW_RELIC_APP_NAME}" >> "$ini"; fi; \
  # Use abstract UNIX socket (Linux): DO NOT add :31339 when using @newrelic \
  if grep -qE '^\s*newrelic\.daemon\.address\s*=' "$ini"; then \
    sed -i -E "s#^\s*newrelic\.daemon\.address\s*=.*#newrelic.daemon.address = ${NEW_RELIC_DAEMON_ADDRESS}#g" "$ini"; \
  else echo "newrelic.daemon.address = ${NEW_RELIC_DAEMON_ADDRESS}" >> "$ini"; fi; \
  # Append your requested tuning block \
  cat >> "$ini" <<'INI_EOF'

; --- Custom tuning ---
; Use an abstract UNIX socket (Linux only) — make sure the DAEMON listens on the SAME address  \
; Recommended default name is @newrelic-daemon
newrelic.daemon.address = "@newrelic"

; Let the agent auto-launch the daemon when running single-container
; (set to 1 if you run the daemon as a separate service)
newrelic.daemon.dont_launch = 0

; Tracing
newrelic.distributed_tracing_enabled = true
newrelic.transaction_tracer.enabled = true
newrelic.transaction_events.enabled = true
newrelic.transaction_tracer.detail = 1
newrelic.attributes.enabled = true

; Errors
newrelic.error_collector.enabled = true
newrelic.error_collector.record_database_errors = true
newrelic.error_collector.ignore_errors = E_WARNING | E_USER_WARNING | E_DEPRECATED | E_USER_DEPRECATED

; Databases
newrelic.datastore_tracer.instance_reporting.enabled = true
newrelic.datastore_tracer.database_name_reporting.enabled = true

; Avoid noise from health checks (see step 3 for finer control)
newrelic.browser_monitoring.auto_instrument = false

; Application
newrelic.application_logging.forwarding.enabled = true
newrelic.application_logging.forwarding.log_level = "ERROR"
INI_EOF
# ---- dev ----

FROM base AS dev
ARG WWWUSER=1000
ARG WWWGROUP=1000
RUN addgroup -g $WWWGROUP app && adduser -G app -g app -s /bin/sh -D -u $WWWUSER app
USER app
CMD ["php-fpm", "-R"]

# ---- app (prod skeleton, optional) ----
FROM base AS app
COPY . .
USER www-data
CMD ["php-fpm", "-R"]
