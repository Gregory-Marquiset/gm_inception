# syntax=docker/dockerfile:1
FROM debian:bullseye-slim
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
&& apt-get upgrade \
&& apt-get install -y --no-install-recommends \
    nginx \
    openssl \
&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/conf.d /etc/ssl/private /etc/ssl/certs

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/conf.d/ /etc/nginx/conf.d/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 443
ENTRYPOINT [ "entrypoint.sh" ]
CMD ["nginx", "-g", "daemon off;"]
