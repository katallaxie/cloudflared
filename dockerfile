# use a distroless base image with glibc
FROM gcr.io/distroless/base-debian13:nonroot@sha256:b78832f41c8128046807c24840ebee4f1c18ba7870eed423d8750c272c15e147

LABEL org.opencontainers.image.source="https://github.com/cloudflare/cloudflared"

# copy our compiled binary
COPY --chown=nonroot --chmod=755 cloudflared/cloudflared /usr/local/bin/cloudflared

# run as nonroot user
# We need to use numeric user id's because Kubernetes doesn't support strings:
# https://github.com/kubernetes/kubernetes/blob/v1.33.2/pkg/kubelet/kuberuntime/security_context_others.go#L49
# The `nonroot` user maps to `65532`, from: https://github.com/GoogleContainerTools/distroless/blob/main/common/variables.bzl#L18
USER 65532:65532

# command / entrypoint of container
ENTRYPOINT ["cloudflared", "--no-autoupdate"]
CMD ["version"]
