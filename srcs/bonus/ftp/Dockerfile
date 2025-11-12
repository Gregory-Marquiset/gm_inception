FROM alpine:3.20
RUN apk add --no-cache vsftpd bash shadow libcap gettext
COPY vsftpd.conf.template /etc/vsftpd/vsftpd.conf.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh", "/usr/sbin/vsftpd"]
