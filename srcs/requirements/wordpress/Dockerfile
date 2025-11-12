FROM alpine:3.20

RUN apk add --no-cache \
    php82 php82-fpm php82-cli php82-curl php82-mysqli php82-opcache php82-json \
    php82-mbstring php82-zip php82-xml php82-gd php82-phar php82-dom php82-tokenizer php82-ctype \
    php82-pecl-redis \
    curl tar fcgi

RUN curl -fsSL -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
 && chmod +x /usr/local/bin/wp \
 && ln -sf /usr/bin/php82 /usr/bin/php

RUN addgroup -S www && adduser -S -G www www

RUN mkdir -p /var/www/html /var/run/php-fpm \
 && chown -R www:www /var/www /var/run/php-fpm

COPY conf/php-fpm.conf /etc/php82/php-fpm.conf
COPY conf/www.conf      /etc/php82/php-fpm.d/www.conf

COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER www

EXPOSE 9000

HEALTHCHECK --interval=10s --timeout=3s --retries=5 \
  CMD SCRIPT_NAME=/fpm-ping SCRIPT_FILENAME=/fpm-ping REQUEST_METHOD=GET \
      cgi-fcgi -bind -connect 127.0.0.1:9000 | grep -q "pong" || exit 1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm82", "-F"]
