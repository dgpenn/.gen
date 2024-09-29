#!/usr/bin/env bash
#
# builds and installs yay
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"
PACKAGES="git base-devel"

function install_yay {

$LOG -i "Installing packages"
pacman-need "$PACKAGES"

}

function configure_yay {

$LOG -i "Cloning yay's repository"
cd /tmp || exit 1
git clone https://aur.archlinux.org/yay.git 2>&1 | $LOG -n git -i -

if [[ -d "/tmp/yay" ]]; then

    $LOG -i "Installing yay"
    cd /tmp/yay || exit 1
    makepkg  \
    --install \
    --syncdeps \
    --check \
    --noconfirm \
    --needed \
    --noprogressbar \
    --nocolor 2>&1 | $LOG -n makepkg -i -

    $LOG -i "Deleting yay repository"
    rm -rf /tmp/yay

    $LOG -i "Configuring yay options"
    yay -Y --combinedupgrade --batchinstall --sudoloop --save

    $LOG -i "To update the system, use \"yay\" with no arguments"

fi

}

if [[ $EUID -eq 0 ]]; then
    require_root
    install_yay
else
    require_user
    configure_yay
fi
