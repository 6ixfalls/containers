#!/bin/sh
set -eu

rules_dir=/var/lib/spamassassin
previous=$(readlink "$rules_dir/active")
staging=$(mktemp -d "$rules_dir/.rules.XXXXXX")

cleanup() {
    if [ "$(readlink "$rules_dir/active")" != "${staging##*/}" ]; then
        rm -rf "$staging"
    fi
}
trap cleanup EXIT

# Keep the current rules available while sa-update verifies and installs the next set.
cp -R "$rules_dir/active/." "$staging"
status=0
timeout -k 5 30 sa-update --gpghomedir "$HOME/.sa-update-keys" --updatedir "$staging" || status=$?
case "$status" in
    0)
        ln -s "${staging##*/}" "$staging/activate"
        mv -Tf "$staging/activate" "$rules_dir/active"
        rm -rf "$rules_dir/${previous:?}"
        printf '%s\n' 'SpamAssassin rules updated.'
        if [ -n "${1:-}" ] && [ -s "$1" ]; then
            kill -HUP "$(cat "$1")"
        fi
        ;;
    1) ;;
    *) printf 'SpamAssassin rule update failed (exit %s). Using the existing rules.\n' "$status" >&2; exit "$status" ;;
esac
