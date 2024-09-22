#!/usr/bin/env bash
#
# adds specific (terrible) modules to blacklist
#
# TODO: Change blacklisting to not introduce duplicates
#

PARENT=$(dirname "$0")
source "$PARENT/common.sh"
BLACKLIST='/etc/modprobe.d/blacklist.conf'
MODULES=(
'pcspkr'
'nouveau'
)

function configure_blacklist {

$LOG -i "Writing module blacklist"
touch "${BLACKLIST}"
for ((i = 0; i < ${#MODULES[@]}; i++))
do
    module="${MODULES[$i]}"
    if grep -q "^blacklist ${module}" "${BLACKLIST}"; then
        $LOG -i "Found \"${module}\" blacklisted"
    else
        $LOG -i "Blacklisting \"${module}\""
        echo "blacklist ${module}" >> "${BLACKLIST}"
    fi
done

$LOG -w "Currently loaded modules will NOT be unloaded!"
}

require_root
configure_blacklist
