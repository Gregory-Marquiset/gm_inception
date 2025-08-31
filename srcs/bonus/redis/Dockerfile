FROM alpine:3.19

RUN apk add --no-cache redis
# user non-root
RUN adduser -S -D -H -h /nonexistent -s /sbin/nologin redisuser \
 && mkdir -p /data && chown -R redisuser /data

USER redisuser
EXPOSE 6379

HEALTHCHECK --interval=10s --timeout=3s --retries=5 \
  CMD redis-cli -h 127.0.0.1 ping | grep -q PONG || exit 1

CMD ["redis-server","--bind","0.0.0.0","--port","6379","--save","","--appendonly","no"]
