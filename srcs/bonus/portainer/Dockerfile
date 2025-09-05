FROM alpine:3.19

# Outils: curl, certs, apache2-utils (pour générer un hash bcrypt)
RUN apk add --no-cache ca-certificates curl bash apache2-utils tzdata wget

WORKDIR /opt/portainer

# Optionnel: pinner une version précise (ex: 2.21.5) via ARG,
# sinon on prendra automatiquement la dernière release.
ARG PORTAINER_VERSION=""

# Télécharge l’archive AMD64 depuis GitHub (latest par défaut)
RUN set -eux; \
  if [ -n "$PORTAINER_VERSION" ]; then \
    # Essaie 2 patrons de noms selon les versions
    URL1="https://github.com/portainer/portainer/releases/download/${PORTAINER_VERSION}/portainer-${PORTAINER_VERSION}-linux-amd64.tar.gz"; \
    URL2="https://github.com/portainer/portainer/releases/download/${PORTAINER_VERSION}/portainer-ce-${PORTAINER_VERSION}-linux-amd64.tar.gz"; \
    curl -fSL "$URL1" -o /tmp/portainer.tgz || curl -fSL "$URL2" -o /tmp/portainer.tgz; \
  else \
    # Dernière release: on détecte l’asset linux-amd64 par grep (pas de jq)
    ASSET_URL="$(curl -fsSL https://api.github.com/repos/portainer/portainer/releases/latest \
      | grep -oE 'https://[^"]+linux-amd64[^"]+\.tar\.gz' | head -n1)"; \
    [ -n "$ASSET_URL" ]; \
    curl -fsSLo /tmp/portainer.tgz "$ASSET_URL"; \
  fi; \
  tar -xzf /tmp/portainer.tgz -C /opt/portainer; \
  rm -f /tmp/portainer.tgz

# Entrypoint qui provisionne le mot de passe admin au 1er run
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/data"]
EXPOSE 9443 8000

# Healthcheck simple sur l’API (cert auto-signé côté Portainer)
HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
  CMD wget -qO- https://127.0.0.1:9443/api/status --no-check-certificate || exit 1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/opt/portainer/portainer", "--data", "/data"]
