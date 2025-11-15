FROM alpine:3.20

RUN apk add --no-cache curl ca-certificates apache2-utils

RUN	set eux; \
	curl -fsSL -o /tmp/portainer.tgz \
	"https://github.com/portainer/portainer/releases/download/2.33.3/portainer-2.33.3-linux-amd64.tar.gz" && \
	tar -xzvf /tmp/portainer.tgz -C /usr/local && \
	rm -f /tmp/portainer.tgz;

ENTRYPOINT ["/usr/local/portainer/portainer"]

EXPOSE 9443
