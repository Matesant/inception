FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
    php php-fpm php-mysql wget unzip curl mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && chmod +x wp-cli.phar \
  && mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /var/www/wordpress

COPY ./tools/entrypoint.sh /entrypoint.sh

COPY ./config/www.conf /etc/php/7.4/fpm/pool.d/www.conf

RUN chmod +x /entrypoint.sh

WORKDIR /var/www/wordpress

CMD ["/entrypoint.sh"]
