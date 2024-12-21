#!/usr/bin/env bash
#
# runs bootstrap
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"
PKG_GROUPS="minimal"

function main {
    bootstrap_mnt "$PKG_GROUPS"
}

require_root
main
