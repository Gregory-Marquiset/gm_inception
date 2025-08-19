FROM alpine:3.19

RUN apk add --no-cache nginx openssl ca-certificates wget

RUN addgroup -S nginx-user && adduser -S -G nginx-user nginx-user

RUN mkdir -p /var/run/nginx /var/cache/nginx /etc/nginx/conf.d /etc/nginx/ssl \
    && chown -R nginx-user:nginx-user /var/run/nginx /var/cache/nginx /etc/nginx /var/log/nginx /var/lib/nginx

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER nginx-user

EXPOSE 8443

HEALTHCHECK --interval=10s --timeout=3s --retries=5 \
  CMD wget -qO- https://localhost:8443/health --no-check-certificate || exit 1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx","-g","daemon off;"]
