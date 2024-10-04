#!/usr/bin/env bash
#
# configures pacman
#
# Some options are set as defined by the OPTIONS array
# Options in array that are already set, regardless of value, are skipped
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"
PACKAGES="pacutils pacman-contrib pkgfile reflector rsync"

function configure_pacman {

$LOG -i "Installing packages"
pacman-need

# Configure pacman
PACMAN_CONFIG='/etc/pacman.conf'

OPTIONS=(
'Color'
'CheckSpace'
'ParallelDownloads = 20'
'VerbosePkgLists'
'ILoveCandy'
)

options_to_apply=''

$LOG -i "Checking options"
for ((i = 0; i < ${#OPTIONS[@]}; i++))
do
    # Full option with value
    option="${OPTIONS[$i]}"

    # Option name (left of "=")
    option_name=$(echo "${option}" | awk '{ print $1 }')

    # Option value (right of "=") or NOTSET
    value="NOTSET"
    if [[ "${option}" == *'='* ]]; then
        value=$(echo "${option}" | awk -F'=' '{ print $2 }' | sed -e 's/ //g')
    fi

    # Skip existing options in configuration
    if [[ $(pacconf "${option_name}" 2>/dev/null) == "${option}" ]]; then
        $LOG -i "Skipping ${option_name}"
        continue
    elif [[ $(pacconf "${option_name}" 2>/dev/null) == "${value}" ]]; then
        $LOG -i "Skipping ${option_name}"
        continue
    fi

    # Handle special case "ILoveCandy"
    if [[ ${option_name}  == "ILoveCandy" ]]; then
        if grep -q 'ILoveCandy' "$PACMAN_CONFIG"; then
            $LOG -i "Skipping ${option_name}"
            continue
        fi
    fi

    # Add option to be applied
    $LOG -i "Adding ${option_name}"
    options_to_apply+="${option}\n"
done

# Apply options
if [[ -z "${options_to_apply}" ]]; then
    $LOG -i "No options were applied."
else
    sed  -i "/^\[options\]$/a ${options_to_apply}" "${PACMAN_CONFIG}"
    $LOG -i "Options were applied."
fi

# Configure pkgfile
$LOG -i "Updating pkgfile database"
pkgfile --raw --update | $LOG -n pkgfile -x -

$LOG -i "Enabling daily pkgfile timer"
systemctl enable pkgfile-update.timer

# Configure reflector
$LOG -i "Writing reflector.conf"
mkdir -p /etc/xdg/reflector
cat <<-EOF > /etc/xdg/reflector/reflector.conf
--save /etc/pacman.d/mirrorlist
--protocol https
--country CH,IS,RO,ES
--score 50
--sort rate
EOF

$LOG -i "Fetching ranked mirrorlist"
systemctl start reflector.service

$LOG -i "Enabling weekly reflector timer"
systemctl enable reflector.timer

}

require_root
configure_pacman
