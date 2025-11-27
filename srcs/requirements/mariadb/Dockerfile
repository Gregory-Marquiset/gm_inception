FROM alpine:3.21

ARG HOST_UID=1000
ARG HOST_GID=1000

RUN apk add --no-cache mariadb mariadb-client

RUN deluser mysql || true && delgroup mysql || true && \
    addgroup -g ${HOST_GID} mysql && \
    adduser -D -H -u ${HOST_UID} -G mysql mysql

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

# tester la db
#   docker exec -it mariadb sh -lc 'mariadb -u"$MYSQL_USER" -p"$(cat //run/secrets/mysql_password)" "$MYSQL_DATABASE"'
#   show DATABASES;
#   USE wordpress; SHOW TABLES;
#   SELECT COUNT(*) FROM wp_comments;
#   CREATE TABLE test (
#   -> id AUTO_INCREMENT PRIMARY KEY,
#   -> name VARCHAR(50)
#   -> tag VARCHAR(15)
#   -> );
#   DESCRIBE test
#   INSERT INTO test (name, tag) VALUE ('gregory', 'gmarquis');
#   SELECT * FROM test