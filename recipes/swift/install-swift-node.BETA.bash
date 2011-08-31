#!/usr/bin/env bash

. env

# Install the packages
apt-get install swift-account swift-container swift-object xfsprogs

# Format and mount the device we want to use
device="/dev/vdb"
echo -e "n\np\n1\n\n\nt\n83\nw" | fdisk $device
mkfs $device

mkfs.xfs -i size=1024 $device

echo "${device}1 /srv/node/${device}1 vfs noatime,nodirtime,nobarrier,logbufs=8 0 0" >> /etc/fstab

# Setup the directories for swift to use it
mkdir -p /srv/node/${device}1
mount /srv/node/${device}1
chown -R swift:swift /srv/node

# Get our IP address
my_ip=$( ifconfig eth0 | grep "inet addr" | awk '{ print $2 }' | awk -F: '{ print $2 }' )

# Generate the rsyncd.conf
cat >/etc/rsyncd.conf <<EOF

uid = swift
gid = swift
log file = /var/log/rsyncd.log
pid file = /var/run/rsyncd.pid
address = $my_ip

[account]
max connections = 2
path = /srv/node/
read only = false
lock file = /var/lock/account.lock

[container]
max connections = 2
path = /srv/node
read only = false
lock file = /var/lock/container.lock

[object]
max connections = 2
path = /srv/node/
read only = false
lock file = /var/lock/object.lock
EOF

# Enable rsyncd at boot
sed -i 's/RSYNC_ENABLE=false/RSYNC_ENABLE=true/' /etc/default/rsync

# Fire up the rsyncd
service rsyncd start

# Create account-server.conf
cat >/etc/swift/account-server.conf <<EOF
[DEFAULT]
bind_ip = $my_ip
workers = 2

[pipeline:main]
pipeline = account-server
mount_check = false

[account-server]
use = egg:swift#account

[account-replicator]

[account-auditor]

[account-reaper]
EOF

cat >/etc/swift/container-server.conf <<EOF
[DEFAULT]
bind_ip = $my_ip
workers = 2

[pipeline:main]
pipeline = container-server

[container-server]
use = egg:swift#container

[container-replicator]

[container-updater]

[container-auditor]
EOF

cat >/etc/swift/object-server.conf <<EOF
[DEFAULT]
bind_ip = $my_ip
workers = 2

[pipeline:main]
use = egg:swift#object

[object-replicator]

[object-updater]

[object-auditor]
EOF

# Start the storage services
swift-init object-server start
swift-init object-replicator start
swift-init object-updater start
swift-init object-auditor start
swift-init container-server start
swift-init container-replicator start
swift-init container-updater start
swift-init container-auditor start
swift-init account-server start
swift-init account-replicator start
swift-init account-auditor start
