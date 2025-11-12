FROM alpine:3.20

# outils + docker CLI minimal
RUN apk add --no-cache \
      ca-certificates curl tar libc6-compat \
      docker-cli

# installe compose v2 au bon chemin de plugin
ARG COMPOSE_VERSION=v2.30.3
ARG TARGETARCH
RUN set -eux; \
  case "${TARGETARCH}" in \
    amd64)  CARCH=x86_64 ;; \
    arm64)  CARCH=aarch64 ;; \
    arm)    CARCH=armv7 ;; \
    *) echo "Unsupported arch: ${TARGETARCH}"; exit 1 ;; \
  esac; \
  curl -fsSL -o /tmp/docker-compose \
    "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-${CARCH}"; \
  chmod +x /tmp/docker-compose; \
  # chemins standards reconnus par le client Docker
  install -Dm0755 /tmp/docker-compose /usr/local/libexec/docker/cli-plugins/docker-compose; \
  install -Dm0755 /tmp/docker-compose /usr/libexec/docker/cli-plugins/docker-compose; \
  install -Dm0755 /tmp/docker-compose /usr/local/lib/docker/cli-plugins/docker-compose; \
  install -Dm0755 /tmp/docker-compose /usr/lib/docker/cli-plugins/docker-compose; \
  # DOCKER_CONFIG (~/.docker) pour l'utilisateur root (Portainer tourne en root chez toi)
  mkdir -p /root/.docker/cli-plugins; \
  cp /tmp/docker-compose /root/.docker/cli-plugins/docker-compose; \
  # alias legacy (certaines détections checkent encore ce nom)
  ln -sf /usr/local/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose; \
  rm -f /tmp/docker-compose

# optionnel mais utile : rendre explicite le DOCKER_CONFIG
ENV DOCKER_CONFIG=/root/.docker

# télécharge Portainer (binaire + assets public/)
ARG PORTAINER_VERSION=2.21.5
WORKDIR /opt/portainer
RUN set -eux; \
  case "${TARGETARCH}" in \
    amd64) ARCH="linux-amd64" ;; \
    arm64) ARCH="linux-arm64" ;; \
    arm)   ARCH="linux-arm-v7" ;; \
  esac; \
  URL_BASE="https://github.com/portainer/portainer/releases/download/${PORTAINER_VERSION}"; \
  curl -fsSL -o portainer.tgz "${URL_BASE}/portainer-${PORTAINER_VERSION}-${ARCH}.tar.gz"; \
  tar -xzf portainer.tgz --strip-components=1; \
  rm -f portainer.tgz; \
  install -m 0755 portainer /usr/local/bin/portainer

VOLUME ["/data"]
EXPOSE 9443
HEALTHCHECK --interval=10s --timeout=5s --retries=10 \
  CMD curl -fsSk https://127.0.0.1:9443/api/system/status >/dev/null || exit 1

ENTRYPOINT ["/usr/local/bin/portainer"]


