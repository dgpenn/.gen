#!/usr/bin/env bash
#
# installs the bare minimum to run xorg-server
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"

PACKAGES='xorg-server xorg-xinit xorg-twm xterm'

function configure_xorg_server {
pacman-need
}

require_root
configure_xorg_server
