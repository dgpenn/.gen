#!/usr/bin/env bash
#
# installs and enables NetworkManager
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"
PACKAGES="networkmanager"

function configure_network_manager {

$LOG -i "Installing packages"
pacman-need

$LOG -i "Enabling NetworkManager"
systemctl enable NetworkManager.service
}

require_root
configure_network_manager
