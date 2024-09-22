#!/usr/bin/env bash
#
# sets deny = 0 to disable locking by pam_faillock after multiple failed logins
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"

function configure_faillock {

$LOG -i "Setting deny = 0"
$LOG -w "This may increase risk if similar mechanisms to lock after failed logins are absent"
if grep -q /etc/security/faillock.conf -ie '^deny\s\+=\s\+0'; then
    $LOG -i "Skipping - Setting already configured"
else
    echo 'deny = 0' >> /etc/security/faillock.conf
    $LOG -i "Setting configured"
fi

}

require_root
configure_faillock
