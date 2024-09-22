#!/usr/bin/env bash
#
# removes the common XDG home dirs and remakes them
# a non-empty directory will exit the script with error
# the following are set:
# - documents
# - music
# - pictures
# - templates
# - videos
# - *; anything else is set to $HOME
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"
PACKAGES='xdg-user-dirs xdg-utils python-pyxdg'

COMMON_XDG_DIRS=(
    Desktop
    Documents
    Downloads
    Music
    Pictures
    Public
    Templates
    Videos
)

XDG_VARS=(
    DOWNLOAD
    DESKTOP
    DOCUMENTS
    MUSIC
    PICTURES
    TEMPLATES
    VIDEOS
    PUBLICSHARE
)

function configure_xdg_dirs {

pacman-need

$LOG -i "Removing specific XDG dirs"
for v in "${COMMON_XDG_DIRS[@]}"
    do
        if [[ -d "${HOME}/${v}" ]]; then
            $LOG -i "Removing ${HOME}/${v}"
            if ! rmdir "${HOME}/${v}"; then
                $LOG -e "Failed to remove ${HOME}/${v}!"
                $LOG -e "Is ${HOME}/${v} empty?"
                exit 1
            fi
        fi
    done

$LOG -i "Updating the user-dir.dirs"
xdg-user-dirs-update --set DOWNLOAD    "${HOME}"
xdg-user-dirs-update --set DESKTOP     "${HOME}"
xdg-user-dirs-update --set DOCUMENTS   "${HOME}/documents"
xdg-user-dirs-update --set MUSIC       "${HOME}/music"
xdg-user-dirs-update --set PICTURES    "${HOME}/pictures"
xdg-user-dirs-update --set TEMPLATES   "${HOME}/templates"
xdg-user-dirs-update --set VIDEOS      "${HOME}/videos"
xdg-user-dirs-update --set PUBLICSHARE "${HOME}"

$LOG -i "Creating missing dirs"
for v in "${XDG_VARS[@]}"
    do
        new_dir="$(xdg-user-dir "${v}")"
        if [[ ! -d "${new_dir}" ]]; then
            $LOG -i "Creating ${v}: ${new_dir}"
            mkdir -p "${new_dir}"
        fi
    done

}

$LOG -w "This script configures the current user ONLY!"
$LOG -w "Re-run this script for each desired user!"

configure_xdg_dirs
