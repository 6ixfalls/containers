ARG VERSION

FROM registry.k8s.io/kubectl:$VERSION AS kubectl

FROM alpine:3.23

COPY --from=kubectl /bin/kubectl /usr/local/bin/kubectl

USER nobody

ENTRYPOINT ["/usr/local/bin/kubectl"]

