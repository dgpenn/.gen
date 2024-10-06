# About Fingerprints

Add polkit and a polkit authentication agent

    sudo pacman -S polkit polkit-gnome

Ensure the polkit authentication agent is started in background when using a GUI

    if [[ -f /usr/lib64/polkit-gnome/polkit-gnome-authentication-agent-1 ]]; then
        sleep 1 && /usr/lib64/polkit-gnome/polkit-gnome-authentication-agent-1 &
    fi

Enroll a fingerprint. Refer to manpage for more information and how to enroll more fingerprints.

    fprintd-enroll

Edit the various PAM configurations to allow fingerprints to be used in lieu of passwords

    Add `auth sufficient pam_fprintd.so` to the top of `/etc/pam.d/sudo` for sudo.
    Add `auth sufficient pam_fprintd.so` to the top of `/etc/pam.d/system-local-login` for local login.
