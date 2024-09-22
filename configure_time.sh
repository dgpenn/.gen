#!/usr/bin/env bash
#
# Sets timezone, sets NTP settings, and syncs clock
#

# TODO: Figure out what functions can(not) run in chroot

PARENT=$(dirname "$0")
source "$PARENT/common.sh"
TIMEZONE="America/New_York"

function configure_time {

$LOG -i "Writing timesyncd.conf drop-in configuration"
mkdir -p /etc/systemd/timesyncd.conf.d/
cat <<-EOF > /etc/systemd/timesyncd.conf.d/us.conf
[Time]
NTP=0.us.pool.ntp.org 1.us.pool.ntp.org 2.us.pool.ntp.org 3.us.pool.ntp.org
FallbackNTP=0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org
EOF

if systemd-detect-virt --chroot; then
    $LOG -i "Detected environment is a chroot"

    $LOG -i "Configuring timezone to $TIMEZONE (firstboot)"
    systemd-firstboot --timezone=$TIMEZONE
else
    $LOG -i "Detected environment is NOT a chroot"

    $LOG -i "Configuring timezone to $TIMEZONE"
    timedatectl --no-pager set-timezone $TIMEZONE

    $LOG -i "Enabling NTP"
    timedatectl --no-pager set-ntp true

    $LOG -i "Setting RTC to UTC and syncing"
    timedatectl --no-pager set-local-rtc 0
fi

}

require_root
configure_time
