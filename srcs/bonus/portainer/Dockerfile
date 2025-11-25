FROM alpine:3.21

RUN apk add --no-cache curl ca-certificates apache2-utils

RUN wget https://github.com/portainer/portainer/releases/download/2.33.3/portainer-2.33.3-linux-amd64.tar.gz && \
    tar -xzvf portainer-2.33.3-linux-amd64.tar.gz && \
    mv portainer /usr/local/. && \
    rm -f portainer-2.33.3-linux-amd64.tar.gz;

WORKDIR /usr/local/portainer

RUN mkdir -p /usr/local/portainer/public/locales/en-US && \
    cp /usr/local/portainer/public/locales/en/translation.json \
       /usr/local/portainer/public/locales/en-US/translation.json

COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 9443
