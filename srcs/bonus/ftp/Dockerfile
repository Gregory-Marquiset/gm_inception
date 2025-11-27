FROM alpine:3.21

RUN apk add --no-cache vsftpd bash shadow libcap gettext

COPY conf/vsftpd.conf.template /etc/vsftpd/vsftpd.conf.template
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh", "/usr/sbin/vsftpd"]

#   tester ftp
#       echo "test 123!" > test.txt
#       ftp 127.0.0.1
#       put text.txt
#       bye
#       https://gmarquis.42.fr/wp-content/uploads/test.txt