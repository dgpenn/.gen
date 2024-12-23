#!/usr/bin/env bash
#
# installs and enables bluetooth
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"
PACKAGES="bluez bluez-utils"

function configure_bluez {

$LOG -i "Enabling bluez"
systemctl enable bluetooth
}

require_root

$LOG -i "Installing packages"
pacman-need

configure_bluez
