#!/bin/bash
set -e

WG_CONF=${WG_CONF:-wg0}

cleanup() {
    echo "Stopping WireGuard interface $WG_CONF"
    wg-quick down "$WG_CONF" || true
    exit 0
}

trap cleanup SIGTERM SIGINT

echo "Starting WireGuard interface $WG_CONF"
wg-quick up "$WG_CONF"

# Wait indefinitely until signaled
while :; do sleep 60; done