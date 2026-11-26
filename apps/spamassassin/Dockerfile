FROM alpine:3.23

ARG VERSION

RUN apk add --no-cache \
    spamassassin="${VERSION}" \
    spamassassin-client="${VERSION}" \
    && apk add --no-cache --virtual .rules-deps gpg-agent \
    && sa-update \
    && apk del .rules-deps \
    && addgroup -S spamassassin \
    && adduser -S -G spamassassin -h /home/spamassassin spamassassin

ENV HOME=/home/spamassassin
USER spamassassin:spamassassin

EXPOSE 783/tcp
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s \
    CMD ["/usr/bin/spamc", "-K", "-x", "-d", "127.0.0.1", "-n", "2", "-t", "2"]

ENTRYPOINT ["/usr/sbin/spamd"]
CMD ["--listen=0.0.0.0", "--allowed-ips=127.0.0.1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16", "--nouser-config", "--syslog=stderr"]
