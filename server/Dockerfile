FROM node:22-bookworm-slim AS assets
WORKDIR /build
COPY package.json package-lock.json vite.config.js ./
RUN npm ci --no-audit --no-fund
COPY resources ./resources
RUN npm run build

FROM composer:2 AS composer

FROM dunglas/frankenphp:1-php8.4-bookworm
WORKDIR /app
RUN install-php-extensions pdo_pgsql intl zip gmp opcache
COPY --from=composer /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
COPY . .
RUN composer install --no-dev --no-interaction --optimize-autoloader \
    && printf 'upload_max_filesize=6M\npost_max_size=10M\nopcache.enable=1\n' > "$PHP_INI_DIR/conf.d/talbytk.ini" \
    && mkdir -p storage/app/public storage/app/private storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs \
    && ln -s ../storage/app/public public/storage \
    && chown -R www-data:www-data /app/storage /app/bootstrap/cache
COPY --from=assets /build/public/build ./public/build

ENV XDG_CONFIG_HOME=/tmp/caddy-config XDG_DATA_HOME=/tmp/caddy-data
USER www-data
EXPOSE 10000
ENTRYPOINT ["/bin/sh", "/app/deploy/start-render.sh"]
