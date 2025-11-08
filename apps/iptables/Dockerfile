FROM alpine:3.22

ARG VERSION

RUN apk add --no-cache iptables="${VERSION}"

CMD ["/usr/sbin/iptables"]
