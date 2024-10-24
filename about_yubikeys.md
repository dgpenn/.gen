# Yubikey

References:

-   https://www.procustodibus.com/blog/2023/04/how-to-set-up-a-yubikey/#openpgp
-   https://github.com/drduh/YubiKey-Guide

## About

The vast majority of this document is a copy of the information from the references.
There are some differences, but this document is mostly a place to store the information in a controlled way.

## OpenPGP Application

While GPG is configured and can be used for SSH, this is mostly an example. Other methods are easier to use.

Ensure GPG has been configured already.

Ensure the pcsd.socket has been started.

    sudo systemctl start pcscd.socket

Insert the yubikey and ensure the yubikey is detected.

    gpg --card-status

Reset the GPG card if needed.

    gpg --edit-card
    admin # Enable admin commands
    factory-reset # Reset all OpenPGP information

Erase any previously generated keys from the computer's keyring if needed.

    gpg --delete-secret-and-public-keys

Re-open the card for editing and set the User and Admin PINs.

    gpg --edit-card
    admin # Enable admin commands

    passwd
    1 # Change PIN; Default is 123456

    3 # Change Admin PIN; Default is 12345678

    q # Quit

Set the key attributes to Curve 25519 keys and generate new keys.

    gpg --edit-card
    admin

    key-attr

    # Signature Key
    2 # ECC
    1 # Curve 25519

    # Encryption Key
    2 # ECC
    1 # Curve 25519

    # Authentication Key
    2 # ECC
    1 # Curve 25519

    # Check the new key attributes
    list

    # Generate the keys
    generate

    # Do not make an off-card backup
    n

    # Set the key expiration to not expire
    0

    # Acknowledge the details are correct
    y

    # Set the Real Name to anything desired
    Fake Name

    # Set the email address to anything desired
    fake@example.com

    # Set the comment to something useful
    Key 42

    # Acknowledge that the information is okay
    o

    # Look at the newly generated keys
    list

    # Exit gpg
    quit

Set the settings for the OpenPGP application on the Yubikey

    # View settings
    ykman openpgp info

    # Set the number of retries for each PIN
    ykman openpgp access set-retries 9 9 9

    # Enter the Admin PIN when prompted and confirm
    y

    # Require a touch for signature key
    ykman openpgp keys set-touch sig cached

    # Require a touch for encryption key
    ykman openpgp keys set-touch dec cached

    # Require a touch for authentication key
    ykman openpgp keys set-touch aut cached

Test the GPG keys

    echo test | gpg -se -u "Key 42" -r "Key 42" | gpg -d
    # - Enter the user pin as prompted (to encrypt)
    # - Touch the Yubikey
    # - Enter the user pin again (to decrupt)

Export the GPG Keys

    gpg --armor --export "Key 42" > Fake_Name_Key_42.asc
    # To import, use "gpg --import Fake_Name_Key_42.asc"

Send the GPG keys to keyserver in ~/.gnupg/gpg.conf

    gpg --send-keys 0xABCDEF1234567890 # The Key ID can be found in the "gpg --list-keys" output next to "pub"

To use GPG keys with SSH

    gpg --export-ssh-key "Key 42" # The output of this goes into the ~/.ssh/authorized_keys file on SSH server

SSH can be tested with something similar to the below

    SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket) ssh fake@ssh.example.com

## PIV

TODO

## FIDO

Check FIDO information

    ykman fido info

Set the FIDO PIN

    ykman fido access change-pin

To delete a resident credential

    ykman fido credentials list
    ykman fido credentials delete <credential_id>
    # Enter PIN if prompted

To fully revoke all credentials, including non-resident credentials, reset the FIDO application.
This will delete the secret master key needed to decrypt any existing FIDO credentials.
Any websites using generated FIDO credentials will need an alternative authentication method!

    ykman fido reset

## OTP

There are 2 slots that can contain 1 of 4 different credentials

1. YubiCloud secret
2. TOTP (Time-based One Time Password) secret
3. HOTP (HMAC-based One Time Password) secret
4. A static secret (up to 38 characters; essentially just a string)

Delete the default secret in slot 1 for YubiCloud.

    ykman otp delete 1

Use the following command to delete instead if an access code was set previously

    ykman otp --access-code - delete 1

To setup a static secret on slot 1

    ykman otp static --generate --length 38 1

To set up an access code (12 hexadecimal characters) on slot 1

    ykman otp settings --new-access-code - 1
