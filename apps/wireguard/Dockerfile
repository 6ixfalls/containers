FROM alpine:3.23

ARG VERSION
ARG IPTABLES_VERSION

COPY --chmod=0755 ./entrypoint.sh /entrypoint.sh

RUN apk add --no-cache wireguard-tools="${VERSION}" iptables="${IPTABLES_VERSION}"

RUN mkdir -p /etc/wireguard/

CMD ["/entrypoint.sh"]