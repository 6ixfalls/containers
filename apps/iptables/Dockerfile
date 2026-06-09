FROM alpine:3.23

ARG VERSION

RUN apk add --no-cache iptables="${VERSION}"

CMD ["/usr/sbin/iptables"]
