ARG VERSION

FROM ghcr.io/sirrobot01/decypharr:${VERSION}

RUN groupadd -g 1000 decypharr && \
    useradd -u 1000 -g decypharr -m decypharr

USER decypharr
