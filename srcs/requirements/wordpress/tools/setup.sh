#!/bin/bash

# Instala WordPress se não estiver instalado
if [ ! -f wp-config.php ]; then
  echo "🔧 Baixando WordPress..."
  wget https://wordpress.org/latest.tar.gz
  tar -xzf latest.tar.gz --strip-components=1
  rm latest.tar.gz

  echo "⚙️ Configurando wp-config.php..."
  cp wp-config-sample.php wp-config.php

  sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/" wp-config.php
  sed -i "s/username_here/${WORDPRESS_DB_USER}/" wp-config.php
  sed -i "s/password_here/${WORDPRESS_DB_PASSWORD}/" wp-config.php
  sed -i "s/localhost/${WORDPRESS_DB_HOST}/" wp-config.php
fi

echo "🚀 Iniciando PHP-FPM..."
mkdir -p /run/php
exec php-fpm7.4 -F
