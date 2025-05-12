FROM debian:bullseye

RUN apt-get update && apt-get install -y nginx openssl

COPY ./config/default.conf /etc/nginx/conf.d/default.conf
COPY ./tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

CMD ["/setup.sh"]
