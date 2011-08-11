#!/usr/bin/env bash

# Script to clean instances before they are snapshotted. If you think of something else to add, feel free

sudo rm -f /root/.*hist* $HOME/.*hist*
sudo find / -name authorized_keys | xargs rm -rf
sudo rm -f /var/log/*
sudo find /var/log -name mysql -prune -o -type f -print | 
  while read i; do sudo cp /dev/null $i; done
