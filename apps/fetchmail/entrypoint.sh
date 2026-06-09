#!/bin/sh

run() {
    if [ -z "$DOMAIN_PASSWORDS" ]; then
        echo "DOMAIN_PASSWORDS not set. Exiting."
        exit 1
    fi

    cat <<EOF > "/data/etc/fetchmailrc"
set no syslog
set logfile /data/log/fetchmail.log

set postmaster "fetchmail"

set no bouncemail
set no spambounce
set no softbounce
set invisible

EOF
    IFS=','
    for PAIR in $DOMAIN_PASSWORDS; do
        DOMAIN=$(echo "$PAIR" | cut -d':' -f1)
        PASSWORD=$(echo "$PAIR" | cut -d':' -f2)

        generate_config "$DOMAIN" "$PASSWORD" >> "/data/etc/fetchmailrc"
    done

    chmod 0600 /data/etc/fetchmailrc
    chown fetchmail:fetchmail /data/etc/
    chown fetchmail:fetchmail /data/etc/fetchmailrc
    touch /data/log/fetchmail.log
    chown fetchmail:fetchmail /data/log/fetchmail.log
    crond
    tail -n 50 -f /data/log/fetchmail.log &
    su -s /bin/sh -c '/bin/sh /bin/fetchmail_daemon.sh' fetchmail
}

generate_config() {
    DOMAIN=$1
    PASSWORD=$2

    cat <<EOF
poll mail.$DOMAIN with proto IMAP
    localdomains $DOMAIN
    auth password
    envelope 'Envelope-to'
    user 'inbound@$DOMAIN' there with password '$PASSWORD' is '*' here
    smtphost localhost/20381

EOF
}

mkdir -p /data /data/etc /data/log
run
