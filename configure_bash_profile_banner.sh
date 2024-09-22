#!/usr/bin/env bash

PARENT=$(dirname "$0")
source "$PARENT/common.sh"

function configure_bash_profile_banner {

$LOG -i "Writing system profile banner"
cat <<-'EOF' > /etc/profile.d/banner.sh
#!/usr/bin/env bash

function print_welcome_msg {
    echo ""
    echo "~ Welcome to $HOSTNAME! ~"
    echo ""
}

function print_ssh_msg {
    REMOTE_IP=$(echo "$SSH_CONNECTION" | awk -F' ' '{printf $1}')
    [[ -n "$SSH_CONNECTION" ]] && echo "- SSH Source: $REMOTE_IP"
}

function print_update_msg {
    updates=$(checkupdates 2>/dev/null)
    code="$?"
    if [[ "$code" -eq 0 ]]; then
        number=$(echo "$updates" | wc -l)
        echo -e "- There is $number update(s) pending."
    elif [[ "$code" -eq 1 ]]; then
        echo -e "- Update check failed. Run \"checkupdates\" manually."
    elif [[ "$code" -eq 2 ]]; then
        echo -e "- There are no updates pending."
    fi
}

# Print login messages
print_welcome_msg
print_ssh_msg
print_update_msg
echo ""
EOF
}

require_root
configure_bash_profile_banner
