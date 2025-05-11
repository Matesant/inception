#!/bin/bash

mkdir -p /etc/nginx/ssl

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/nginx.key \
  -out /etc/nginx/ssl/nginx.crt \
  -subj "/C=BR/ST=42/L=Intra/O=42SP/CN=${DOMAIN_NAME}"

exec nginx -g "daemon off;"
