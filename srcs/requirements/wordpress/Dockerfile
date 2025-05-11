FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    php php-fpm php-mysql wget unzip curl mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Cria diretório do WordPress
RUN mkdir -p /var/www/wordpress

# Copia script de setup
COPY ./tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

WORKDIR /var/www/wordpress

CMD ["/setup.sh"]
