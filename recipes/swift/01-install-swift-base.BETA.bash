#!/usr/bin/env bash

. .env

# Since this is a work in progress you must remove this to actually make it run
echo "This is considered BETA and may not entirely work yet. Remove the exit 1 in the code if you really want to run it"
exit 1

repo="ppa:swift-core/release"

# Install the required repos and software
apt-get -y install python-software-properties
add-apt-repository $repo
apt-get update
apt-get -y install swift openssh-server rsyncd

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

# Create the environment on our nodes
for i in $zone1_ip $zone2_ip $zone3_ip; do
  ssh -i $ssh_key $i "apt-get -y install python-software-properties && add-apt-repository $repo && apt-get update && apt-get -y install swift openssh-server && mkdir -p /etc/swift"
  scp -i $ssh_key /etc/swift/swift.conf $i:/etc/swift
  ssh -i $ssh_key $i "chown -R swift:swift /etc/swift"
done
