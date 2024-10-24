# About S.M.A.R.T.

## References:

-   https://wiki.archlinux.org/title/S.M.A.R.T.

## About

This file contains instructions and information about smartmontools and monitoring S.M.A.R.T. information. Most of the information is mostly likely a "copy pasta" job with edits.

## Details

S.M.A.R.T. is mostly about running tests built into each drive by the manufacturer. These ultimately result in a health status for each drive. The drive's health can be monitored by periodically running tests and the information logged so the drives can be replaced before failure.

Ideally, the information logged will be reviewed or a script configured to alert any administrator.

## Instructions

1.  Install smartmontools

        pacman -S smartmontools

2.  Test the drives initially using a conveyance test or short test. New drives should not have large amounts of errors.

        smartctl -x /dev/sda # see drive information
        smartctl -t conveyance /dev/sda # start test; usually ~5 minutes

3.  Check the drive health and see see if the test passed. If drives are failing, they will probably fail very soon. Copy any data off soon.

        smartctl -H /dev/sda

4.  Once drives are verified, configure the daemon with desired settings. For an example configuration for two SATA disks, see below.

        cat <<-'EOF' > /etc/smartd.conf

        # DEFAULT directive applies to every device given after

        # Specifying a disk by UUID is preferred to be more specific
        # E.g. /dev/disk/by-uuid/<uuid>

        # -a = "default", implies -H -f -t -l error -l selftest -l selfteststs -C 197 -U 198; this is probably wanted. See man smartd.conf

        # -o on = enables automatic "offline" tests; these are generally harmless and won't cause performance issues

        # -S on = enables attribute autosave; This is should be set once to ensure vendor-specific attributes are kept across power cycles

        # -s (S/../.././03|L/../../5/10) = Scheduled Tests; This is short tests on every day at 0300 and long tests on Friday at 1000
        ## This format is (T/MM/DD/d/HH) where T is the test S,L,C,O,n,r,c = short,long,conveyance,offline,next-span,redo-span,continue-span
        ### MM is Month 01-12, DD is day 01-31, d is 1-7 where 1 is Monday, HH is time range where 00 is midnight to just before 1am; Do not add/remove zeroes.
        #### For the span tests, see man information on "smartctl -t select,[next|redo|cont]"
        ##### As an example, a long test on a 20TB drive can take a full day, so it is best scheduled when it won't be accessed or in chunks.

        # -n never,q = Prevent a disk from spinning up when polled by smartd; never means to spin the disk up regardless of power state (default)
        ## q means to suppress any log messages about smartctl skipping any periodic tests if needed

        # -W 0,0,0 = Warn on drive temperature changes; Format is DIFF,INFO,CRIT; DIFF is report if there is at least DIFF change from last report or new min/max
        ## INFO and CRIT cause a report or warning if temperature reaches those thresholds; 0 disables each item; -m (send mail) will be used with CRIT
        ### Temperature is Celsius; Drive temperatures should be checked and thresholds determined based on "normal" temperatures

        DEFAULT -a -o on -S on -s (S/../.././03|L/../../5/10) -n never,q -W 0,0,0
        /dev/sda
        /dev/sdb
        EOF

5.  Once all settings are configured, enable and start the daemon.

        sudo systemctl enable smartd.service --now
