#!/usr/bin/env bash
#
# configures (disables) brltty
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"

function configure_brltty {

$LOG -i "Masking brltty.path"
systemctl mask brltty.path

}

require_root
configure_brltty
