FROM alpine:3.20

RUN apk add --no-cache wget apache2-utils

RUN	wget https://github.com/portainer/portainer/releases/download/2.33.3/portainer-2.33.3-linux-amd64.tar.gz && \
	tar -xzvf portainer-2.33.3-linux-amd64.tar.gz && \
	mv portainer /usr/local/. && \
	rm -f portainer-2.33.3-linux-amd64.tar.gz;

ENTRYPOINT ["/usr/local/portainer/portainer"]

EXPOSE 9443
#CMD ["sleep", "5000"]