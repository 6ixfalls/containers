FROM ubuntu:24.04

# renovate: datasource=repology depName=ubuntu_24_04/net-snmp versioning=loose
ENV NET_SNMP_VERSION="5.9.4+dfsg-1.1ubuntu3.1"

RUN apt-get update && apt-get install -y --no-install-recommends \
    snmpd="${NET_SNMP_VERSION}" \
    libsnmp-perl="${NET_SNMP_VERSION}" \
    gettext \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/snmp/

EXPOSE 161/udp

CMD ["snmpd", "-f"]