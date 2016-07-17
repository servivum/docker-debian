#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x

DAEMON=supervisord

# Copy public key
if [ -f authorized_keys ]; then
    cp authorized_keys /root/.ssh/authorized_keys
    chown -R root:root ~/.ssh
    chmod 700 /root/.ssh/
    chmod 600 /root/.ssh/*
fi

# Copy default config from cache
if [ ! "$(ls -A /etc/ssh)" ]; then
   cp -a /etc/ssh.cache/* /etc/ssh/
fi

# Generate Host keys, if required
if [ ! -f /etc/ssh/ssh_host_* ]; then
    ssh-keygen -A
fi

# Fix permissions, if writable
if [ -w ~/.ssh ]; then
    chown -R root:root ~/.ssh && chmod 700 ~/.ssh/ && chmod 600 ~/.ssh/* || echo "WARNING: No SSH authorized_keys or config found for root"
fi

# Configure sSMTP
if [ "$SMTP_HOST" ]; then
    echo "mailhub=$SMTP_HOST" >> /etc/ssmtp/ssmtp.conf
fi;
if [ "$SMTP_AUTH_USER" ]; then
    echo "AuthUser=$SMTP_AUTH_USER" >> /etc/ssmtp/ssmtp.conf
fi;
if [ "$SMTP_AUTH_PASS" ]; then
    echo "AuthPass=$SMTP_AUTH_PASS" >> /etc/ssmtp/ssmtp.conf
fi;

if [ "$SSMTP_AUTH_PASS" ]; then
    echo "UseSTARTTLS=YES" >> /etc/ssmtp/ssmtp.conf
fi;

stop() {
    echo "Received SIGINT or SIGTERM. Shutting down $DAEMON"
    # Get PID
    pid=$(cat /var/run/$DAEMON/$DAEMON.pid)
    # Set TERM
    kill -SIGTERM "${pid}"
    # Wait for exit
    wait "${pid}"
    # All done.
    echo "Done."
}

echo "Running $@"
if [ "$(basename $1)" == "$DAEMON" ]; then
    trap stop SIGINT SIGTERM
    $@ &
    pid="$!"
    mkdir -p /var/run/$DAEMON && echo "${pid}" > /var/run/$DAEMON/$DAEMON.pid
    wait "${pid}" && exit $?
else
    exec "$@"
fi