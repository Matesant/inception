FROM debian:oldstable

RUN apt update && apt install -y mariadb-server

RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld && \
    chmod 777 /var/run/mysqld

COPY ./conf/db_conf.conf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY ./tools/init_db.sh /docker-entrypoint-initdb.d/init_db.sh

RUN chmod +x /docker-entrypoint-initdb.d/init_db.sh

EXPOSE 3306

CMD ["mysqld", "--bind-address=0.0.0.0"]