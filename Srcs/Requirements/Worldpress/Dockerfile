FROM debian:bullseye-slim
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
&& apt-get upgrade \
&& apt-get install -y --no-install-recommends \
    php-fpm php-mysql php-gd php-xml php-mbstring php-curl \
    wget ca-certificates \
&& rm -rf /var/lib/apt/lists/*

COPY conf/php-fpm.conf /etc/php/7.4/fpm/pool.d/www.conf

RUN mkdir -p /var/www/html \
&& wget -qO- https://wordpress.org/latest.tar.gz | tar zxC /var/www/html --strip-components=1 \
&& chown -R www-data:www-data /var/www/html

COPY wp-entrypoint.sh /usr/local/bin/wp-entrypoint.sh
RUN chmod +x /usr/local/bin/wp-entrypoint.sh

WORKDIR /var/www/html
VOLUME ["/var/www/html"]

EXPOSE 9000
ENTRYPOINT ["wp-entrypoint.sh"]
CMD ["php-fpm", "-F"]
