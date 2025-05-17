#!/bin/bash

# ────────────────────────────────────────────────────────────────────────────────
# 1. Generate self-signed SSL certificate
# ────────────────────────────────────────────────────────────────────────────────
mkdir -p /etc/nginx/ssl

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/nginx.key \
  -out /etc/nginx/ssl/nginx.crt \
  -subj "/C=BR/ST=SP/L=SP/O=42/OU=42SP/CN=matesant.42.fr"

# ────────────────────────────────────────────────────────────────────────────────
# 2. Wait for WordPress (php-fpm) to be ready
# ────────────────────────────────────────────────────────────────────────────────
echo "🔁 Waiting for WordPress (php-fpm) to be ready..."

until nc -z wordpress 9000; do
  echo "⏳ Waiting for php-fpm on wordpress:9000..."
  sleep 2
done

echo "✅ WordPress is ready!"

# ────────────────────────────────────────────────────────────────────────────────
# 3. Start NGINX in foreground
# ────────────────────────────────────────────────────────────────────────────────
exec nginx -g "daemon off;"
