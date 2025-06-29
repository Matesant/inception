FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get install -y nginx openssl netcat && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./config/default.conf /etc/nginx/conf.d/default.conf
COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 443

CMD ["/entrypoint.sh"]
