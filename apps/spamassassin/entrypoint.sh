#!/bin/sh
set -eu

case "${1:-}" in
    -h|--help|-V|--version) exec /usr/sbin/spamd "$@" ;;
esac

refresh-rules.sh || :

case "$(printf '%s' "${ENABLE_UPDATES:-TRUE}" | tr '[:upper:]' '[:lower:]')" in
    true|yes|on|1)
        runtime_dir=$(mktemp -d /tmp/spamd.XXXXXX)
        pidfile="$runtime_dir/spamd.pid"
        printf '%s /usr/local/bin/refresh-rules.sh %s\n' \
            "${UPDATE_PERIOD:-15 23 * * *}" "$pidfile" > "$runtime_dir/crontab"
        (
            trap '' HUP
            until [ -s "$pidfile" ]; do sleep 1; done
            exec supercronic -quiet "$runtime_dir/crontab"
        ) &
        set -- "$@" "--pidfile=$pidfile"
        ;;
esac

exec /usr/sbin/spamd "$@"
