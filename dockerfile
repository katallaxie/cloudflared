# use a distroless base image with glibc
FROM debian:13-slim

RUN \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        ca-certificates && \
    apt-get autoclean && \
    rm -rf \
      /var/lib/apt/lists/* \
      /var/tmp/* \
      /tmp/*

ENV TUNNEL_TOKEN=

COPY --chmod=0755 /cloudflared/cloudflared /usr/local/bin

# command / entrypoint of container
ENTRYPOINT ["cloudflared"]
CMD ["tunnel", "--no-autoupdate", "run", "--token", "$TUNNEL_TOKEN"]
