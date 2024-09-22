#!/usr/bin/env bash
#
# common functions to be sourced via other scripts
#

SCRIPT=$(basename "$0")
PARENT=$(dirname "$0")
LOGGER=$(which "$PARENT/logger.py")
LOG="$LOGGER -n $SCRIPT "

function require_root {
    if [[ $EUID -ne 0 ]]; then
        $LOG -e "Run this script as root!"
        exit 1
    fi
}

function require_user {
    if [[ $EUID -eq 0 ]]; then
        $LOG -e "Do NOT run this script as root!"
        exit 1
    fi
}

function pacman-need {

    $LOG -i "Checking for needed packages"
    if [[ ! -z  "$1" ]]; then
        $LOG -i "Packages specified via arg"
        in_var="${1}"
    elif [[ ! -z "$PACKAGES" ]]; then
        $LOG -i "Packages specified via "PACKAGES" var"
        in_var="${PACKAGES}"
    else
        $LOG -w "No packages specified"
        return 2
    fi

    IFS=' ' read -r -a packages <<< "${in_var}"
    type yay > /dev/null 2>&1
    if [[ "$?" -eq 0 && "${UID}" -ne 0 ]]; then
        installer='yay'
        extra_options="--sudoloop"
    else
        installer='pacman'
        extra_options=""
        if [[ ${EUID} -ne 0 ]]; then
            installer="sudo pacman"
        fi
    fi
    $LOG -i "Installing needed packages"
    $LOG -i "Set \"$installer\" as installer"
    $LOG -i "Running $installer"
    $installer --sync --quiet --refresh --sysupgrade --needed --noconfirm $extra_options "${packages[@]}" 2>&1 | $LOG -n $installer -i -
    sleep 0.5 # Wait to ensure consecutive calls do not lock pacman database
}

# This is a shim and does not work with yay
function sudo_exec {
    if [[ "$EUID" -eq 0 ]]; then
        $LOG -i "Detected EUID (${EUID})"
    else
        $LOG -i "Script requires root privileges"
        $LOG -i "Detected non-zero EUID (${EUID})"
        $LOG -i "Re-executing script with sudo"
        exec sudo "$0" "$@"
    fi
}
