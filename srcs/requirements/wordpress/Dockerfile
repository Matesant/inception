FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    php php-fpm php-mysql wget unzip curl mariadb-client \
    && rm -rf /var/lib/apt/lists/*

    # Instala WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Cria diretório do WordPress
RUN mkdir -p /var/www/wordpress

# Copia script de setup
COPY ./tools/setup.sh /setup.sh
COPY ./config/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY ./static/index.html /var/www/wordpress/index.html


RUN chmod +x /setup.sh

WORKDIR /var/www/wordpress

CMD ["/setup.sh"]
