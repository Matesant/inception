FROM debian:bullseye

RUN apt-get update && apt-get install -y nginx openssl

COPY ./conf/default.conf /etc/nginx/sites-available/default
COPY ./tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

CMD ["/setup.sh"]
