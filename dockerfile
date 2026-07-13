# Stage 1: Use Debian base for building cloudflared
FROM debian:stable AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    pkg-config \
    libssl-dev \
    ca-certificates \
    curl \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Stage 2: Minimal runtime image
FROM busybox:stable-glibc

ENV PATH=/usr/local/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin

RUN addgroup -g 10001 cloudflared && \
    adduser -D -H -u 10001 -G cloudflared cloudflared

RUN mkdir -p /etc/cloudflared && \
    chown 10001:10001 /etc/cloudflared

# Copy root CA certificates from the builder stage
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo

COPY --chown=10001:10001 --chmod=755 /cloudflared/cloudflared /usr/local/bin/cloudflared

ENV TZ=UTC

USER 10001:10001

# command / entrypoint of container
ENTRYPOINT ["cloudflared"]
CMD ["tunnel", "--no-autoupdate", "run"]
