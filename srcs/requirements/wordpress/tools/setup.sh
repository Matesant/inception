#!/bin/bash

cd /var/www/wordpress

# Instala WordPress se ainda não existir
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

echo "⏳ Aguardando o banco de dados..."
until mysqladmin ping -h"${WORDPRESS_DB_HOST}" -u"${WORDPRESS_DB_USER}" -p"${WORDPRESS_DB_PASSWORD}" --silent; do
  sleep 1
done

if ! wp core is-installed --allow-root; then
  echo "🚀 Instalando WordPress..."
  wp core install \
    --url="https://${DOMAIN_NAME}" \
    --title="Meu Site Inception" \
    --admin_user="${WP_ADMIN}" \
    --admin_password="${WP_ADMIN_PASS}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --allow-root

  echo "💬 Instalando plugin de comentários"
  wp plugin install wpdiscuz --activate --allow-root

  echo "💬 Ativando comentários globais"
  wp option update default_comment_status open --allow-root

  echo "📝 Criando post com comentários ativados"
  wp post create \
    --post_title="Bem-vindo ao Inception!" \
    --post_content="Esse é um post de teste com comentários." \
    --post_status=publish \
    --comment_status=open \
    --allow-root
fi

echo "🚀 Iniciando PHP-FPM..."
mkdir -p /run/php
exec php-fpm7.4 -F
