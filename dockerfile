# Stage 1: Use Debian base for building cloudflared
FROM katallaxie/cloudflared-dev:latest as builder

# Stage 2: Minimal runtime image
FROM debian:stable-slim

ENV PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl && rm -rf /var/lib/apt/lists/*

COPY --from=builder /cloudflared/cloudflared /usr/local/bin/cloudflared

ENV TUNNEL_TOKEN=""

CMD ["sh", "-c", "cloudflared tunnel --no-autoupdate run --token $TUNNEL_TOKEN"]
