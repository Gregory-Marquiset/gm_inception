FROM alpine:3.19

RUN addgroup -S static \
 && adduser  -S -D -H -h /nonexistent -s /sbin/nologin -G static static \
 && apk add --no-cache darkhttpd

COPY site/ /site
RUN chown -R static:static /site \
 && chmod -R a+rX /site

USER static
EXPOSE 8080

HEALTHCHECK --start-period=5s --interval=10s --timeout=3s --retries=5 \
  CMD /bin/busybox wget -qO- http://127.0.0.1:8080/health >/dev/null || exit 1

ENTRYPOINT ["darkhttpd","/site","--port","8080","--addr","0.0.0.0","--log","/dev/stdout","--no-listing"]
