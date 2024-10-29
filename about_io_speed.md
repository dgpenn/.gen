# About I/O Speed

## About

This file is mostly just "quick and dirty" notes about typical network and disk speeds. Some may even be accurate.

## Network Speed

This is a "good enough" method to determine the actual network line speed using netcat.

1.  Install netcat if it is not installed.

        pacman -S openbsd-netcat

2.  Run netcat on the sever machine as a listener.

        nc -vvlnp 8080 >/dev/null

3.  Pipe dd to netcat on the client machine (which connects to the server).

        dd if=/dev/zero bs=1M count=1k | nc -vnn <server-ip> 8080

This will write 1 GiB of data from the client to the server, which pipes it to /dev/null. The output of dd is "good enough" to see the speed, which will usually be expressed in MB/s or GB/s.

E.g. For a 10 Gbps wired network:

-   Multiple tests showed consistent speeds of 1.1-1.2 GB/s as reported by dd (which rounds).
-   Note the unit differences between bytes and bits.
-   An ideal 10 Gbps connection with 1500 byte frames (the standard MTU) should cap out at ~9400 mbps.
    -   Jumbo frames should make this "faster" by increasing the frame size, but all devices in the network path must be configured with the correct MTU.
-   9400mbps is the same as 9.4 Gbps or 1.175 GB/s.
-   Taking the exact bytes and speed reported by dd instead of the reported speed would often result in a speed slightly over the maximum, so this should be taken with a grain of salt.
-   Note that more accurate results might be achieved by writing more data by changing dd's count variable.

## Disk Speeds

A quick Google search indicates a 20TB 7200RPM Seagate Exos X20 drive reports read/write speeds up to 285 MB/s (272 MiB/s).
Many "spinning rust" drives will perform worse than this drive.
In practice, lots of random reads or writes to a drive will cause this value to drop and vary a lot.

1.  To check the drive write speed in a very "rough" manner, use dd.

        dd if=/dev/zero of=/tmp/disk/test.img bs=1G count=1 oflag=dsync
        # Note that /tmp/disk contains the mounted hard drive to be tested

2.  To check the drive read speed with a dedicated utility, use hdparm.

        hdparm -Tt /dev/sda
        # /dev/sda is the drive being tested

E.g. Using 20TB Seagate X20 drives to test read speeds:

-   hdparm's cached reads were up to 18363.31 MB/s for multiple drives
-   hdparm's buffered disk reads were up to 270.58 MB/s for multiple drives
-   hdparm showed a simple average of buffered disk reads across all disks to be about 263 MB/s. Note the system was in use at the time, so results are lower than normal.

## RAID Speeds

The speed of a raid array varies wildly based on the type of raid array, how the array is setup, and what disks make up the array, etc.

Testing an array should probably wait until after the array is properly synced.

The below is an attempt to test speeds so that they can be used in comparison to testing with NFS, CIFS, SSH, etc. This and the network speed testing with netcat above are then used to determine where any bottlenecks lie.

### Example Array

The examples array for the information below will be a Linux MD RAID 10 array with far2 layout.

-   This array contains 5 20TB 7200RPM Seagate Exos X20 drives.
-   On the top of this array is an array-spanning LVM logical volume backed by a SATA SSD "writethrough" cache. A "writeback" cache would presumably be more performant.
-   The SSD cache drive shows buffered disk reads of ~528.56 MB/s using hdparm.

### Writing

Write speeds can be determined roughly using "dd" as seen above for singular disks.

    dd if=/dev/zero of=/tmp/disk/test.img bs=1G count=1 oflag=dsync

E.g. Using the 5 disk array described above:

-   dd's results showed write speeds up to 304 MB/s.
-   The oflag=dsync is an attempt to avoid local caching

### Reading

A similar dd command to the write test command above with the "if" and "of" parameters switched can be used to get "a" read speed. However, this may not avoid all caching in the described array. Various caches that we can discard should be discarded before reading the file.

    echo 3 > /proc/sys/vm/drop_caches
    dd if=/tmp/disk/test.img bs=1G count=1 oflag=dsync

E.g. Using the 5 disk array described above:

-   dd's initial local read results showed read speeds up to 7.3 GB/s, which is _probably_ not accurate in terms of disk performance. Data is likely cached.
-   dd's remote read results by reading the file using an NFS share on a local 10 Gbps connection showed 1.1 GB/s which is 8.8 Gbps.
    -   Subsequent reads showed similar results to the local read speeds of up to 7.3 GB/s.
-   Attempts to re-write the file using random data from a client over NFS and then re-read the file locally from the array showed dips in local read speed down to 3.0 GB/s on the NFS server.
    -   This is still "too fast" indicating that caching is occuring.
-   Attempts to clear the caches and re-read the file on the array locally showed speeds drop to just 922MB/s.

## SSH Speeds

A few comments on SSH:

-   SSH may be limited by CPU performance of the encryption algorithms used.
-   SSH may be limited by implementation. I.e. It needs multithreading to be performant.
-   SSH is limited by configuration.
-   SCP is limited by adding an extra layer of complexity and flow control.

The above is all to say, SSH, and SCP in particular, are generally slow. There are some exceptions and mitigations to this, but when transferring files locally, there are almost always faster methods if the connection does not need encryption.
