FROM alpine:3.23

ARG VERSION
ARG SUPERCRONIC_VERSION
ARG TINI_VERSION

RUN apk add --no-cache \
    gpg-agent \
    spamassassin="${VERSION}" \
    spamassassin-client="${VERSION}" \
    supercronic="${SUPERCRONIC_VERSION}" \
    tini="${TINI_VERSION}" \
    && addgroup -S spamassassin \
    && adduser -S -G spamassassin -h /home/spamassassin spamassassin \
    && sa-update --gpghomedir /home/spamassassin/.sa-update-keys \
    && set -- /var/lib/spamassassin/* \
    && mv "$1" /var/lib/spamassassin/seed \
    && ln -s active "$1" \
    && ln -s seed /var/lib/spamassassin/active \
    && chown -R spamassassin:spamassassin /var/lib/spamassassin /home/spamassassin

COPY --chmod=0755 entrypoint.sh scripts/refresh-rules.sh /usr/local/bin/

ENV HOME=/home/spamassassin
USER spamassassin:spamassassin

EXPOSE 783/tcp
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s \
    CMD ["/usr/bin/spamc", "-K", "-x", "-d", "127.0.0.1", "-n", "2", "-t", "2"]

ENTRYPOINT ["/sbin/tini", "-g", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["--listen=0.0.0.0", "--allowed-ips=127.0.0.1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16", "--nouser-config", "--syslog=stderr"]
