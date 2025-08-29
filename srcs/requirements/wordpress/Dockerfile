FROM alpine:3.19

# PHP 8.2 + extensions WordPress + outils
RUN apk add --no-cache \
    php82 php82-fpm php82-cli php82-curl php82-mysqli php82-opcache php82-json \
    php82-mbstring php82-zip php82-xml php82-gd php82-phar php82-dom php82-tokenizer php82-ctype \
    curl tar fcgi

# Utilisateur non-root
RUN addgroup -S www && adduser -S -G www www

# Dossiers & permissions
RUN mkdir -p /var/www/html /var/run/php-fpm \
 && chown -R www:www /var/www /var/run/php-fpm

# Config PHP-FPM
COPY conf/php-fpm.conf /etc/php82/php-fpm.conf
COPY conf/www.conf      /etc/php82/php-fpm.d/www.conf

# Entrypoint
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER www

EXPOSE 9000

# Healthcheck FastCGI: on attend "pong" du /fpm-ping
HEALTHCHECK --interval=10s --timeout=3s --retries=5 \
  CMD SCRIPT_NAME=/fpm-ping SCRIPT_FILENAME=/fpm-ping REQUEST_METHOD=GET \
      cgi-fcgi -bind -connect 127.0.0.1:9000 | grep -q "pong" || exit 1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm82", "-F"]
