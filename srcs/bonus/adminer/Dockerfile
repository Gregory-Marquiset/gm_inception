FROM alpine:3.19

# PHP minimal pour Adminer (non-root)
RUN apk add --no-cache php82 php82-session php82-mysqli php82-pdo_mysql php82-opcache curl
RUN addgroup -S www && adduser -S -G www www

WORKDIR /var/www
RUN curl -fsSL -o adminer.php https://www.adminer.org/latest.php \
 && ln -s adminer.php index.php \
 && chown -R www:www /var/www

USER www
EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=3s --retries=5 \
  CMD php82 -v >/dev/null 2>&1 || exit 1

# Sert Adminer en avant-plan
CMD ["php82","-S","0.0.0.0:8080","-t","/var/www"]
