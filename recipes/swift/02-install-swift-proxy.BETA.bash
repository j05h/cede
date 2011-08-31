#!/usr/bin/env bash

# Since this is a work in progress you must remove this to actually make it run
echo "This is considered BETA and may not entirely work yet. Remove the exit 1 in the code if you really want to run it"
exit 1

. .env

# Write out our initial config file
cat >/etc/swift/swift.conf <<EOF
[swift-hash]
# random unique string that can never change (DO NOT LOSE)
swift_hash_path_suffix = `od -t x8 -N 8 -A n </dev/random`
EOF

# Own everything to swift
chown -R swift:swift /etc/swift/

# Install the proxy
apt-get -y install swift-proxy memcached

# Generate an SSL certificate so everything talks securely
cd /etc/swift
openssl req -new -x509 -nodes -out cert.crt -keyout cert.key

# Update the memcached to listen on the correct IP and restart it
perl -pi -e "s/-l 127.0.0.1/-l $PROXY_LOCAL_NET_IP/" /etc/memcached.conf
service memcached restart

# Create /etc/swift/proxy-server.conf (using some variables from above. See, toldja we'd need 'em)
cat >/etc/swift/proxy-server.conf <<EOF
[DEFAULT]
cert_file = /etc/swift/cert.crt
key_file = /etc/swift/cert.key
bind_port = 8080
workers = 8
user = swift

[pipeline:main]
pipeline = healthcheck cache tempauth proxy-server

[app:proxy-server]
use = egg:swift#proxy
allow_account_management = true

[filter:tempauth]
use = egg:swift#tempauth
user_system_root = testpass .admin https://$PROXY_LOCAL_NET_IP:8080/v1/AUTH_system

[filter:healthcheck]
use = egg:swift#healthcheck

[filter:cache]
use = egg:swift#memcache
memcache_servers = $PROXY_LOCAL_NET_IP:11211
EOF

cd /etc/swift
# Gotta put in your partition size, it'll be 2^$SIZE
SIZE=17
REPLICAS=3
HOURS=1

swift-ring-builder account.builder create $SIZE $REPLICAS $HOURS
swift-ring-builder container.builder create $SIZE $REPLICAS $HOURS
swift-ring-builder object.builder create $SIZE $REPLICAS $HOURS

# Add each zone to the ring
## Zone 1
swift-ring-builder account.builder add $zone1-$zone1_ip:6002/$zone1_device $zone1_weight
swift-ring-builder container.builder add $zone1-$zone1_ip:6001/$zone1_device $zone1_weight
swift-ring-builder object.builder add $zone1-$zone1_ip:6000/$zone1_device $zone1_weight

## Zone 2
swift-ring-builder account.builder add $zone2-$zone2_ip:6002/$zone2_device $zone2_weight
swift-ring-builder container.builder add $zone2-$zone2_ip:6001/$zone2_device $zone2_weight
swift-ring-builder object.builder add $zone2-$zone2_ip:6000/$zone2_device $zone2_weight

## Zone 3
swift-ring-builder account.builder add $zone3-$zone3_ip:6002/$zone3_device $zone3_weight
swift-ring-builder container.builder add $zone3-$zone3_ip:6001/$zone3_device $zone3_weight
swift-ring-builder object.builder add $zone3-$zone3_ip:6000/$zone3_device $zone3_weight

# Now we verify each ring's contents
swift-ring-builder account.builder
swift-ring-builder container.builder
swift-ring-builder object.builder

# And finally rebalance them
swift-ring-builder account.builder rebalance
swift-ring-builder container.builder rebalance
swift-ring-builder object.builder rebalance

# Make sure /etc/swift exists on all of our storage nodes
current=$( pwd )
cd /etc/swift
for i in "$zone1_ip" "$zone2_ip" "$zone3_ip"; do
  ssh -i $ssh_key $i "mkdir -p /etc/swift"
  for j in "account.ring.gz" "container.ring.gz" "object.ring.gz" "swift.conf"; do
    scp -i $ssh_key $j $i:/etc/swift/
  done
  ssh -i $ssh_key $i "chown -R swift:swift /etc/swift"
done
