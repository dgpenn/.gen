# Barebones Reference for Terminal Use

## Check Boot Type

    cat /sys/firmware/efi/fw_platform_size

## Check Internet

    ping 1.1.1.1

## Configure Wi-Fi

    iwctl
    station wlan0 scan
    station wlan0 get-networks
    station wlan0 connect "Wifi Network Name"
    quit

## Clone This Repository

    cd /
    pacman -Sy archlinux-keyring
    pacman -Sy git

    git clone https://github.com/dgpenn/dots.git

## Partition Disk

    # This assumes "sda" is the primary disk name
    # Use `lsblk` to check

    parted /dev/sda
    mklabel gpt
    mkpart BIOS_GRUB ext2 1MiB 2MiB # Start from 1MiB and make a 1MiB partition
    mkpart EFI fat32 2MiB 202MiB # Start from last partition's end and make a 200 MiB partition
    mkpart ROOT ext4 202MiB 100% # start from last partition's end and make a partition to fill disk
    set 1 bios_grub on
    set 2 esp on
    type 3 4f68bce3-e8cd-4db1-96e7-fbcaf984b709
    quit

    # The labels set here are partition labels or "partlabels"

    # The "bios_grub" flag tells GRUB where to install (in BIOS/GPT)
    # The format of this parition doesn't matter, GRUB will write directly to it

    # "esp" marks an EFI System Partition and sets the "boot" flag
    # Parition type UUID is "c12a7328-f81f-11d2-ba4b-00a0c93ec93b"
    # type is set automatically by marking esp

    # type 3 4f68bce3-e8cd-4db1-96e7-fbcaf984b709 sets the root partition type code
    # The partiton type UUID stands for "x86_64 Linux Root"

    # See "systemd-gpt-auto-generator" for more  information
    # systemd allows automatic fstab-less mounting (in UEFI/GPT) for certain partition types

## Format Partitions

    mkfs.ext4 -L "ROOT" /dev/disk/by-partlabel/
    mkfs.vfat -F32 -n "EFI" /dev/sda2

## Mount Partitions

    mount /dev/disk/by-label/ROOT /mnt
    mkdir /mnt/efi
    mount /dev/disk/by-label/EFI /mnt/efi

## Install Packages

    pacstrap -K /mnt <packages>

## Generate File System Table

    # This can be skipped on UEFI/GPT
    # systemd can handle /efi and / if partition type UUIDs are set

    genfstab -U /mnt > /mnt/etc/fstab

    # Use -L for labels instead of UUID

## Enter Chroot

    arch-chroot /mnt

## Set Time Zone (./configure_time.sh)

    ln -sf /usr/share/zoneinfo/Ameria/New_York /etc/localtime
    hwclock --systohc

## Set Localization

Uncomment `en_US.UTF-8` and `ja_JP.UTF-8` to set locales in `/etc/locale.gen`

    nano /etc/locale.gen

Set `LANG` in `/etc/locale.conf`

    echo 'LANG=en_US.UTF-8' > /etc/locale.conf

Alternatively, use `systemd-firstboot --locale="en_US.UTF-8"`
or `localectl --no-pager set-locale "en_US.UTF-8"`

## Set Hostname

Set hostname in `/etc/hostname`

    echo "<hostname>" > /etc/hostname

Alternatively, use `systemd-firstboot --hostname=<hostname>`
or `hostnamectl hostname <hostname>`

## Set Hosts

Setup hosts file for the localhost

    nano /etc/hosts

E.g. As an example for the host "skynet" and domain "example.com"

    # 127.0.0.1 localhost
    # ::1       localhost
    # 127.0.1.1 skynet.example.com skynet

Additional entries for other machines can be added as additional entries.

# Setup Dracut (./configure_dracut.sh)

Reference: https://wiki.archlinux.org/title/Dracut

The tldr; version is

-   Use `configure_dracut.sh` to configure and use `dracut_hooks.py`
-   Re-install kernel: `pacman -S linux`
-   Verify dracut was run and an initramfs was generated under /boot

# Install GRUB

Edit /etc/default/grub as needed.

    # E.g.
    # GRUB_TIMEOUT=1
    # GRUB_DISABLE_RECOVERY=true
    # GRUB_DISABLE_SUBMENU=y

For a traditional booting system (or "legacy" or CSM-enabled system)

    grub-install --target=i386-pc /dev/sda

For a UEFI booting system

    grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB

Generate GRUB configuration and ensure the kernel and initramfs image are detected

    grub-mkconfig

Generate and save the configuration

    grub-mkconfig -o /boot/grub/grub.cfg

# Add Sudo User

    useradd -m -G wheel <username>
    passwd <username>

# Setup Sudo

Uncomment appropriate line for wheel group

    EDITOR=nano visudo
    # The line for wheel group without password should look like
    # %wheel ALL=(ALL:ALL) ALL

Login as the sudo user and verify sudo privileges

    sudo whoami # should output "root" as regular user

The root account can be locked once a working sudo user is setup

    passwd -l root
