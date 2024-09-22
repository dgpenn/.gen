#!/usr/bin/env bash
#
# configure ssytem-wide bash-related files
#


PARENT=$(dirname "$0")
source "$PARENT/common.sh"

function configure_bash_users {

$LOG -i "Writing system /etc/bash.bash_logout"
cat <<'EOF' > "/etc/bash.bash_logout"
#!/usr/bin/env bash

clear
reset
EOF

$LOG -i "Writing system /etc/bash.bashrc"
cat <<'EOF' > "/etc/bash.bashrc"
#!/usr/bin/env bash

# If not running interactively, stop and exit
[[ $- != *i* ]] && return

if [[ -r /usr/share/bash-completion/bash_completion ]]; then
  source /usr/share/bash-completion/bash_completion
fi

# Add completions
complete -cf sudo

# Set shell options
shopt -s autocd
shopt -s checkwinsize

# Set prompt string
PS1='[\u@\h \W]\$ '

# Set aliases

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias sudo='sudo -v; sudo '
alias diff='diff --color=auto'

if type whipper > /dev/null 2>&1; then
    alias arip='whipper cd rip --unknown'
fi

if type git > /dev/null 2>&1; then
    alias dots='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
    source /usr/share/bash-completion/completions/git
    __git_complete dots __git_main
fi

if type pkgfile > /dev/null 2>&1; then
    source /usr/share/doc/pkgfile/command-not-found.bash
fi

case ${TERM} in
  Eterm*|alacritty*|aterm*|foot*|gnome*|konsole*|kterm*|putty*|rxvt*|tmux*|xterm*)
    PROMPT_COMMAND+=('printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"')

    ;;
  screen*)
    PROMPT_COMMAND+=('printf "\033_%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"')
    ;;
esac

EOF

}

require_root
configure_bash_users
