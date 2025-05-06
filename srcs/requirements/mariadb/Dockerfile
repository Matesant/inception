FROM debian:oldstable

RUN apt-get update && apt-get install -y mariadb-server \
    && mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld && \
    chmod 777 /var/run/mysqld

COPY ./conf/init_db.sh /init_db.sh

RUN chmod +x /init_db.sh

ENTRYPOINT ["./init_db.sh"]