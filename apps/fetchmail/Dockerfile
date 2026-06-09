FROM alpine:3.23

ARG VERSION
ARG OPENSSL_VERSION
ARG LOGROTATE_VERSION
ARG TINI_VERSION

RUN apk add --no-cache \
    fetchmail="${VERSION}" \
    openssl="${OPENSSL_VERSION}" \
    logrotate="${LOGROTATE_VERSION}" \
    tini="${TINI_VERSION}"

WORKDIR /data

RUN chown fetchmail:fetchmail /data \
    && chmod 0744 /data

COPY ./defaults/logrotate.d/fetchmail /etc/logrotate.d/fetchmail
COPY --chmod=0700 ./entrypoint.sh /bin/start.sh
COPY --chmod=0700 --chown=fetchmail:fetchmail ./scripts/fetchmail_daemon.sh /bin/fetchmail_daemon.sh

VOLUME ["/data"]
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/bin/start.sh"]
