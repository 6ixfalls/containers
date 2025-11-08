FROM alpine:3.22

ARG VERSION

RUN apk add --no-cache iptables="${IPTABLES_VERSION}"

CMD ["/usr/sbin/iptables"]