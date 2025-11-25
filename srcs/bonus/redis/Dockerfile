FROM alpine:3.21

ARG HOST_UID=1000
ARG HOST_GID=1000

RUN apk add --no-cache redis

RUN deluser redisuser 2>/dev/null || true && delgroup redisuser 2>/dev/null || true && \
    addgroup -S -g ${HOST_GID} redisuser && \
    adduser  -S -D -H -h /nonexistent -s /sbin/nologin -G redisuser -u ${HOST_UID} redisuser

COPY tools/entrypoint.sh /entrypoint.sh

RUN mkdir -p /data \
 && chown -R redisuser:redisuser /data /entrypoint.sh \
 && chmod +x /entrypoint.sh

USER redisuser

EXPOSE 6379

HEALTHCHECK --interval=10s --timeout=3s --retries=5 \
  CMD redis-cli -h 127.0.0.1 ping | grep -q PONG || exit 1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["redis-server","--bind","0.0.0.0","--port","6379","--save","","--appendonly","no"]
