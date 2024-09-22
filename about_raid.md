# About Software RAID

## References:

-   https://wiki.archlinux.org/title/RAID
-   https://wiki.archlinux.org/title/LVM_on_software_RAID
-   https://wiki.archlinux.org/title/LVM

## About

This file contains instructions and notes on how a particular NAS machine (hostname: soul) was setup. It's an example more than a guide.

## Notes

This machine has the following hardware:

-   1 M.2 NVME drive for OS
-   1 SSD for LVM (RAID array) cache
-   5 20TB HDDs
-   64GB RAM
-   10G NIC

This machine has the following names:

-   `nvme0n1` (OS drive)
-   `sda` (LVM cache)
-   `sdb`,`sdc`,`sdd`,`sde`,`sdf` (RAID array drives)
-   `md127` (raid array device name; use `lsblk` or check `/dev` after initial mdadm commands to determine)
-   `qi` (name of raid array; an arbitrary name)
-   `vg_ectoplasm`, `lv_ectoplasm`, `cache_ectoplasm_cpool` (names of LVM volume group, logical volume, and cachepool; `_cpool` is added automatically, all names are still arbitrary)
-   LVM is used mostly for simplicity's sake to allow for a form of read caching and easy expansion. There are other, possibly better, options.

## Instructions

1.  Install mdadm and lvm2 packages

        pacman -S mdadm lvm2

2.  Verify device names and erase drives as needed. Most drives are physically labeled with serial numbers.

        lsblk -o name,serial,size

        mdadm --misc --zero-superblock /dev/sdb
        mdadm --misc --zero-superblock /dev/sdc
        mdadm --misc --zero-superblock /dev/sdd
        mdadm --misc --zero-superblock /dev/sde
        mdadm --misc --zero-superblock /dev/sdf

3.  Partition each drive. Leave a small amount of space unused to ensure any drive replacements won't be too small.

    Use parted to see total size of drive in MiB

    e.g. parted --> unit MiB --> print

    20TB Seagate Exos is 19074048MiB

    Partions span 1MiB --> 19073947MiB (100MiB left unused as buffer)

    Create new partition table

        parted -s /dev/sdb mklabel gpt
        parted -s /dev/sdc mklabel gpt
        parted -s /dev/sdd mklabel gpt
        parted -s /dev/sde mklabel gpt
        parted -s /dev/sdf mklabel gpt

    Make a single partition to span each drive

        parted -s mkpart ext4 1MiB 19073947MiBMiB /dev/sdb
        parted -s mkpart ext4 1MiB 19073947MiBMiB /dev/sdc
        parted -s mkpart ext4 1MiB 19073947MiBMiB /dev/sdd
        parted -s mkpart ext4 1MiB 19073947MiBMiB /dev/sde
        parted -s mkpart ext4 1MiB 19073947MiBMiB /dev/sdf

    Flag each new device as part of a raid array

        parted -s set 1 raid on /dev/sdb
        parted -s set 2 raid on /dev/sdc
        parted -s set 3 raid on /dev/sdd
        parted -s set 4 raid on /dev/sde
        parted -s set 5 raid on /dev/sdf

4.  Build the array

        mdadm --create --verbose --level=10 --metadata=1.2 --chunk=512 --raid-devices=5 --layout=f2 /dev/md/qi /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1 /dev/sdf1

5.  Write the mdadm.conf

    Ensure output appears correct before writing to configuration

        mdadm --detail --scan

    Write the configuration

        mdadm --detail --scan > /etc/mdadm.conf

6.  Assemble the array

        mdadm --assemble --scan

7.  Verify chunk size

        mdadm --detail /dev/md127 | grep 'Chunk Size'

8.  Setup array as an LVM physical volume

        pvcreate /dev/md127

9.  Create LVM volume group

        vgcreate vg_ectoplasm /dev/md127

10. Create LVM logical volume to span array

        lvcreate -l 100%FREE vg_ectoplasm -n lv_ectoplasm

11. Add extra drive (sda) as LVM cache

    Add cache drive to volume group

        vgextend vg_ectoplasm /dev/sda

    Add drive as cache pool

        # Note this "cache" is generally a "read" oriented cache
        # The mode "writethrough" is less performant than "writeback" but ensures less risk if cache fails while writing

        lvcreate --type cache --cachemode writethrough -l 100%FREE -n cache_ectoplasm vg_ectoplasm/lv_ectoplasm /dev/sda

12. Ensure RAID scrubbing is enabled to run periodically.

        # on Arch, using AUR
        yay -S raid-check-systemd
        systemctl enable raid-check.timer --now

        # To start a scrub manually, use the below command
        echo check > /sys/block/md127/md/sync_action

13. Assuming system is not being used, the resync of drives can be increased using the commands below. This will use more resources and possibly make other tasks sluggish.

        sysctl -w dev.raid.speed_limit_min=2000000
        sysctl -w dev.raid.speed_limit_max=2000000

        # Use "sysctl dev.raid.speed_limit_min" or "sysctl dev.raid.speed_limit_max" to check settings
        # These settings will be reset upon reboot

14. Monitor the resync progress using `/proc/mdstat`

        watch -n 0.1 cat /proc/mdstat

15. Add array to `/etc/fstab` to mount on boot.

        sudo nano /etc/fstab
        # Add a line similar to the below
        # UUID can be found using blkid

        # UUID=868a99aa-1b30-4ed3-8360-40244c905043   /storage    ext4    defaults,noatime,user,exec,nofail,x-systemd.device-timeout=30    0 2

        # defaults is equivalent to rw,suid,dev,exec,auto,nouser,async

        # user implies noexec,nosuid,nodev, allows a single user to mount and unmount

        # users is same as user but allows any user to mount or unmount regardless of who mounted the disk originally

        # noatime is better for drive health; implies nodiratime

        # exec overrides noexec to allow program execution on this device

        # nofail allows the system to ignore the device and continue on boot

        # x-system.device-timeout allows the timeout to be set lower than the default (90)

        # Note x-systemd.automount would allow this device to be auto-mounted only upon initial access; this is NOT wanted as it causes some issues with other services sometimes, which expect the location to be immediately available
