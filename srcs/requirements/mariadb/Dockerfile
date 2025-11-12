FROM alpine:3.20

RUN apk add --no-cache mariadb mariadb-client

RUN mkdir -p /run/mysqld /var/lib/mysql \
 && chown -R mysql:mysql /run/mysqld /var/lib/mysql

COPY conf/server.cnf /etc/my.cnf.d/server.cnf
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER mysql

EXPOSE 3306

HEALTHCHECK --interval=10s --timeout=3s --retries=5 \
  CMD mariadb-admin ping -h 127.0.0.1 -uroot -p"$MYSQL_ROOT_PASSWORD" --silent || exit 1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["mysqld"]
