FROM debian:oldstable

RUN apt-get update && apt-get install -y \
    php-fpm php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip \
    wget unzip \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://wordpress.org/latest.tar.gz \
    && tar -xvzf latest.tar.gz \
    && rm latest.tar.gz \
    && mv wordpress /var/www/html

WORKDIR /var/www/html

# COPY conf/ /etc/php/

EXPOSE 9000

CMD ["php-fpm7.3", "-F"]
