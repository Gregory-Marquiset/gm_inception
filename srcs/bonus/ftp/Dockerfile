FROM alpine:3.19

RUN apk add --no-cache vsftpd bash shadow libcap coreutils

COPY vsftpd.conf.template /etc/vsftpd/vsftpd.conf.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 21 30000-30009

# petit healthcheck interne (le compose en a aussi un)
HEALTHCHECK --interval=10s --timeout=3s --retries=5 \
  CMD printf 'QUIT\r\n' | nc -w 2 127.0.0.1 21 | grep -q '^220' || exit 1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/vsftpd","/etc/vsftpd/vsftpd.conf"]
