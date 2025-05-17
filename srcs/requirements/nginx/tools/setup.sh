#!/bin/bash

mkdir -p /etc/nginx/ssl

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/nginx.key \
  -out /etc/nginx/ssl/nginx.crt \
  -subj "/C=BR/ST=SP/L=SP/O=42/OU=42SP/CN=matesant.42.fr"

exec nginx -g "daemon off;"
