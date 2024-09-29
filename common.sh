#!/usr/bin/env bash
#
# common functions to be sourced via other scripts
#

SCRIPT=$(basename "$0")
PARENT=$(dirname "$0")
PKG_DIR="$PARENT/packages"
LOGGER=$(which "$PARENT/logger.py")
LOG="$LOGGER -n $SCRIPT "

# shellcheck disable=SC2086
# shellcheck disable=SC2124
function bootstrap_mnt {

    pkg_groups="$@"

    if [[ -z $pkg_groups ]]; then
        $LOG -e "No package groups set!"
        return
    fi

    bootstrap_pkgs=''
    for package_group in "${pkg_groups[@]}"; do

        group_json="$PKG_DIR/$package_group.json"

        if [[ ! -f "$group_json" ]]; then
            $LOG -e "No $group_json was found!"
            exit 1
        fi
        bootstrap_pkgs+=$(jq ".$package_group | join(\" \")" "$group_json" | sed -e 's/\"//g')
        bootstrap_pkgs+=" "
    done
    pacstrap -K /mnt $bootstrap_pkgs | $LOG -n pacstrap -i -
}

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
    if [[ -n  "$1" ]]; then
        $LOG -i "Packages specified via arg"
        in_var="${1}"
    elif [[ -n "$PACKAGES" ]]; then
        $LOG -i 'Packages specified via "PACKAGES" var'
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
    $installer --sync --quiet --refresh --sysupgrade --needed --noconfirm $extra_options "${packages[@]}" 2>&1 | $LOG -n "$installer" -i -
    sleep 0.5 # Wait to ensure consecutive calls do not lock pacman database
}
