#!/bin/sh
swapoff /swapfile
dd if=/dev/zero of=/swapfile bs=1024 count=512K
chown root:root /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
swapon -s
free -m

# cat "/swapfile   none    swap    sw    0   0" >> /etc/fstab