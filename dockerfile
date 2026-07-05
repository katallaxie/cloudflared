# Stage 1: Use Debian base for building cloudflared
FROM golang:1.26-alpine AS builder

# Use a build argument to specify the cloudflared version
ARG CLOUDFLARED_VERSION=master

RUN git clone https://github.com/cloudflare/cloudflared.git /cloudflared

WORKDIR /cloudflared

# Checkout the specified version
RUN git checkout $CLOUDFLARED_VERSION

# Ensure Go is executable
RUN chmod +x /usr/local/go/bin/go

RUN go mod download

RUN GOOS=linux GOARCH=arm GOARM=5 go build -o /cloudflared/cloudflared ./cmd/cloudflared

# Stage 2: Minimal runtime image
FROM debian:stable-slim

ENV PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl && rm -rf /var/lib/apt/lists/*

COPY --from=builder /cloudflared/cloudflared /usr/local/bin/cloudflared

ENV TUNNEL_TOKEN=""

CMD ["sh", "-c", "cloudflared tunnel --no-autoupdate run --token $TUNNEL_TOKEN"]
