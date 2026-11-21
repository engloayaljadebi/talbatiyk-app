#!/bin/sh
set -eu

: "${APP_KEY:?Set Laravel APP_KEY in Render.}"
case "$APP_KEY" in
    base64:*) ;;
    *) export APP_KEY="base64:$APP_KEY" ;;
esac
export APP_URL="${APP_URL:-${RENDER_EXTERNAL_URL:?Set APP_URL or deploy through Render.}}"

if [ "${SUPABASE_STORAGE:-false}" = "true" ]; then
    : "${SUPABASE_URL:?Set the Supabase project URL.}"
    : "${SUPABASE_S3_ENDPOINT:?Set the Supabase S3 endpoint.}"
    : "${SUPABASE_S3_REGION:?Set the Supabase S3 region.}"
    : "${SUPABASE_S3_KEY:?Set the Supabase S3 access key ID.}"
    : "${SUPABASE_S3_SECRET:?Set the Supabase S3 secret access key.}"
    : "${SUPABASE_PUBLIC_BUCKET:?Set the public product images bucket.}"
    : "${SUPABASE_PRIVATE_BUCKET:?Set the private user assets bucket.}"
    if [ "$SUPABASE_PUBLIC_BUCKET" = "$SUPABASE_PRIVATE_BUCKET" ]; then
        printf '%s\n' 'Use distinct buckets for public images and private assets.' >&2
        exit 1
    fi
fi

php artisan config:cache
php artisan migrate --force --no-interaction
php artisan db:seed --force --no-interaction

exec frankenphp run --config /app/deploy/Caddyfile --adapter caddyfile
