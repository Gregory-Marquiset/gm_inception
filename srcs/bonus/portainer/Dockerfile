FROM alpine:3.20

RUN apk add --no-cache wget apache2-utils

RUN	wget https://github.com/portainer/portainer/releases/download/2.14.2/portainer-2.14.2-linux-amd64.tar.gz && \
	tar -xzvf portainer-2.14.2-linux-amd64.tar.gz && \
	mv portainer /usr/local/. && \
	rm -f portainer-2.14.2-linux-amd64.tar.gz;

CMD ["/usr/local/portainer/portainer"]

