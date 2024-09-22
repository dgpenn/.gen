# About Software RAID

## References:

-   https://wiki.archlinux.org/title/NFS
-   https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/managing_file_systems/exporting-nfs-shares_managing-file-systems

## About

This file contains instructions and notes on how a particular NFS Server was setup. It's an example more than a guide.

This particular setup has _NOT_ been reviewed.

## Notes

This machine has the following items:

-   /storage (mounted raid-array, to be shared)
-   /storage/music (folder containing music)
-   /storage/videos (folder containing videos)

The machine has the /storage array mounted with the following /etc/fstab entry. Note that the array is an LVM logical volume on top of a mdadm raid10 array.

    /dev/mapper/<lv-name>   /storage    ext4    defaults,noatime,user,exec,nofail,x-systemd.device-timeout=30    0 2

## Instructions

1.  Install nfs-utils

        pacman -S nfs-utils

2.  Verify the computer time is synced to an NTP server.

        timedatectl status

    If time is not synced

        timedatectl set-ntp true
        timedatectl set-local-rtc true

3.  Setup NFS root folder

        mkdir -p /srv/nfs/
        mkdir /srv/nfs/music
        mkdir /srv/nfs/videos
        mkdir /srv/nfs/storage

4.  Use mount bind to bind the folders to be shared

        mount --bind /storage/music  /srv/nfs/music
        mount --bind /storage/videos /srv/nfs/videos
        mount --bind /storage        /srv/nfs/storage

5.  To make mount bind(s) permanent, edit fstab

        nano /etc/fstab
        # /storage/videos /srv/nfs/videos   none bind 0 0
        # /storage/music  /srv/nfs/music    none bind 0 0
        # /storage        /srv/nfs/storage  none bind 0 0

6.  Add each path to the exports file

        nano /etc/exports

        # fsid=0 identifies nfs root,
        # crossmnt allows clients to access all filesystems mounted on this filesystem
        # id -u noboody to find id(s); 65534 is "nobody" on "this" system;
        # all_squash will forcefully map remote users to anonid,anongid; root_squash will do same for only root
        # sync makes the NFS server not reply to requests before previous requests are written, async is the opposite but allows for potential loss
        # pnfs is only supported by nfsv4 but generally improves speed
        # insecure allows connections from port numbers above 1023
        # <desktop> is an example hostname for a specific computer on the network

        /srv/nfs         192.168.1.0/24(ro,sync,pnfs,crossmnt,fsid=0)

        /srv/nfs/storage          <desktop>(rw,sync,pnfs,all_squash,anonuid=65534,anongid=65534,insecure)

        /srv/nfs/videos  192.168.1.0/24(ro,sync,pnfs,all_squash,anonuid=65534,anongid=65534,insecure)

        /srv/nfs/music   192.168.1.0/24(ro,sync,pnfs,all_squash,anonuid=65534,anongid=65534,insecure)

        # Ensure files are owned by the appropriate user!

7.  Start the nfs-server.service for NFS using protocol version 3.

        systemctl start nfs-server.service
        # nfsv4-server is protocol version 4, but compatibility is lower among clients

8.  If any changes are made to /etc/exports, re-export using `exportfs -arv` or restart the server.

9.  Ensure thw following ports are open for TCP/UDP on server.

    -   111
    -   2049
    -   20048

10. Once the server is confirmed working on all clients, enable it on startup.

        systemctl enable nfs-server.service

11. On clients that may want to auto-mount the server with systemd, use the following fstab entry.

        nano /etc/fstab
        # <server> is an example hostname for the NFS server
        # <mopuntpoint> is where to mount the array
        <server>:/storage   <mountpoint>  nfs  _netdev,noauto,x-systemd.automount,x-systemd.mount-timeout=10,timeo=14,x-systemd.idle-timeout=1min 0 0

12. Reload the daemon to register the changes in /etc/fstab

        systemctl daemon-reload
