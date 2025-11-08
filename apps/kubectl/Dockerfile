FROM alpine:3.22

ARG VERSION

COPY --from=registry.k8s.io/kubectl:$VERSION /bin/kubectl /usr/local/bin/kubectl

USER nobody
ENTRYPOINT ["/usr/local/bin/kubectl"]