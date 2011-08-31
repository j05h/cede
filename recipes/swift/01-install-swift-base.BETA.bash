#!/usr/bin/env bash

. .env

# Since this is a work in progress you must remove this to actually make it run
echo "This is considered BETA and may not entirely work yet. Remove the exit 1 in the code if you really want to run it"
exit 1

# Install the required repos and software
apt-get -y install python-software-properties
add-apt-repository ppa:swift-core/ppa
apt-get update
apt-get -y install swift openssh-server

# Make our config directory
mkdir -p /etc/swift

# Write out our initial config file
cat >/etc/swift/swift.conf <<EOF
[swift-hash]
# random unique string that can never change (DO NOT LOSE)
swift_hash_path_suffix = `od -t x8 -N 8 -A n </dev/random`
EOF

# Own everything to swift
chown -R swift:swift /etc/swift/
