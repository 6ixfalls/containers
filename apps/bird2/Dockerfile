FROM debian:13-slim

ARG VERSION

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bird2="${VERSION}" \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/bird /etc/bird

ENTRYPOINT ["/usr/sbin/bird"]
CMD ["-d", "-s", "/var/run/bird/bird.ctl", "-c", "/etc/bird/bird.conf"]
