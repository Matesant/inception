#!/bin/bash

set -e
cd /var/www/wordpress

check_db() {
  echo "⏳ Verificando banco de dados em ${WORDPRESS_DB_HOST}..."
  mysql -h"${WORDPRESS_DB_HOST}" -u"${WORDPRESS_DB_USER}" -p"${WORDPRESS_DB_PASSWORD}" -e "SHOW DATABASES;" > /dev/null 2>&1
  return $?
}

until check_db; do
  echo "⌛ Aguardando o banco de dados..."
  sleep 3
done
echo "✅ Banco disponível."

# Baixa o WordPress se não estiver presente
if [ ! -f wp-load.php ]; then
  echo "⬇️ Baixando WordPress..."
  wp core download --path=/var/www/wordpress --allow-root
fi

# Instalação e configuração
if ! wp core is-installed --allow-root --path=/var/www/wordpress; then
  echo "🔧 Criando wp-config.php"
  wp config create \
    --dbname=${WORDPRESS_DB_NAME} \
    --dbuser=${WORDPRESS_DB_USER} \
    --dbpass=${WORDPRESS_DB_PASSWORD} \
    --dbhost=${WORDPRESS_DB_HOST} \
    --locale=pt_BR \
    --allow-root \
    --path=/var/www/wordpress

  echo "🚀 Instalando WordPress"
  wp core install \
    --url="https://matesant.42.fr" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN}" \
    --admin_password="${WP_ADMIN_PASS}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --allow-root \
    --path=/var/www/wordpress

  wp plugin install wpdiscuz --activate --allow-root --path=/var/www/wordpress
  wp option update default_comment_status open --allow-root --path=/var/www/wordpress

  wp post create \
    --post_title="Bem-vindo ao Inception!" \
    --post_content="Esse é um post de teste com comentários." \
    --post_status=publish \
    --comment_status=open \
    --allow-root \
    --path=/var/www/wordpress

  wp user create \
    "${WP_VIWER_USER}" "${WP_VIWER_EMAIL}" \
    --role=subscriber \
    --user_pass="${WP_VIWER_PASSWORD}" \
    --allow-root \
    --path=/var/www/wordpress
fi

mkdir -p /run/php
exec php-fpm7.4 -F
