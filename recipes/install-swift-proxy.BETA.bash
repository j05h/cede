#!/usr/bin/env bash

# Since this is a work in progress you must remove this to actually make it run
echo "This is considered BETA and may not entirely work yet. Remove the exit 1 in the code if you really want to run it"
exit 1

# Install the required repos and software
apt-get -y nstall python-software-properties
add-apt-repository ppa:swift-core/ppa
apt-get update
apt-get -y install swift openssh-server

# Set some variables for scripts later
export STORAGE_LOCAL_NET_IP=10.17.1.3
export PROXY_LOCAL_NET_IP=10.17.1.3

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
